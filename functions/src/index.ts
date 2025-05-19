import { onDocumentCreated } from "firebase-functions/v2/firestore"; // v2 Firestore trigger
import { onSchedule, ScheduledEvent } from "firebase-functions/v2/scheduler"; // v2 Scheduled function ve ScheduledEvent türü
import * as logger from "firebase-functions/logger"; // v2 logger
import admin = require("firebase-admin");
import axios from "axios";
import CryptoJS = require("crypto-js");

admin.initializeApp();

const db = admin.firestore();
const fcm = admin.messaging();

// Define interfaces for better type safety
interface IzmirApiRecord {
  ADI: string;
  ENLEM: string | number;
  BOYLAM: string | number;
  MAHALLE?: string;
  YOL?: string;
  KAPINO?: string;
  ACIKLAMA?: string;
  ILCE?: string;
}

interface DonationCenterFirestoreData {
  id: string;
  name: string;
  address: string;
  district?: string;
  province: string;
  phone?: string | null;
  location: admin.firestore.GeoPoint;
  isVerified: boolean;
  source: string;
  updatedAt: admin.firestore.FieldValue;
  createdAt?: admin.firestore.FieldValue;
  website?: string | null;
  email?: string | null;
  imageUrl?: string | null;
  operatingHours?: string | null;
}

const IZBB_KAN_MERKEZLERI_API_URL =
  "https://openapi.izmir.bel.tr/api/ibb/cbs/kanmerkezleri";

// V2 Firestore Trigger
export const sendNotificationOnNewDonationOffer = onDocumentCreated(
  {
    document: "donationResponses/{responseId}",
    region: "europe-west1", // Specify region if needed
  },
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
      logger.error(
        "Yeni bağış teklifi trigger'ı çalıştı ama snapshot (event.data) yok.",
        { eventId: event.id }
      );
      return;
    }

    const offerData = snapshot.data();
    logger.info(
      `Yeni bağış teklifi trigger'ı çalıştı. Response ID: ${snapshot.id}`,
      { offerData: offerData }
    );

    if (!offerData) {
      logger.error("Teklif verisi (offerData) bulunamadı.");
      return;
    }

    const requestId = offerData.requestId as string | undefined;
    const donorName = offerData.donorName as string | undefined;
    const requestCreatorId = offerData.requestCreatorId as string | undefined;

    if (!requestId) {
      logger.error("Teklif verisinde 'requestId' eksik.", { offerData });
      return;
    }
    if (!requestCreatorId) {
      logger.error("Teklif verisinde 'requestCreatorId' eksik.", {
        offerData,
      });
      return;
    }

    try {
      const userDocRef = db.collection("users").doc(requestCreatorId);
      const userDocSnap = await userDocRef.get();

      if (!userDocSnap.exists) {
        logger.error("Talep sahibi kullanıcı bulunamadı:", requestCreatorId);
        return;
      }

      const userData = userDocSnap.data();
      const fcmTokens = userData?.fcmTokens as string[] | undefined;

      if (!fcmTokens || fcmTokens.length === 0) {
        logger.warn(
          `Talep sahibinin (${requestCreatorId}) FCM token'ı bulunamadı ` +
            "veya boş."
        );
        return;
      }

      const requestDocSnap = await db
        .collection("bloodRequests")
        .doc(requestId)
        .get();
      const requestTitle = requestDocSnap.exists
        ? (requestDocSnap.data()?.title as string | undefined) ||
          "kan talebinize"
        : "kan talebinize";

      const notificationPayload: admin.messaging.NotificationMessagePayload = {
        title: "Talebinize Yeni Yanıt!",
        body: `${donorName || "Bir bağışçı"}, "${requestTitle}" yanıt verdi.`,
      };

      const dataPayload: { [key: string]: string } = {
        type: "new_donation_offer",
        routePath: "/manage-donation-offers",
        requestId: requestId,
        clickTimestamp: Date.now().toString(),
      };

      const messageOptions: admin.messaging.MessagingOptions = {
        priority: "high",
      };

      logger.info(
        `Talep sahibine (${requestCreatorId}) bildirim gönderiliyor. ` +
          `Token sayısı: ${fcmTokens.length}`,
        {
          tokens: fcmTokens,
          notification: notificationPayload,
          data: dataPayload,
        }
      );

      const response = await fcm.sendToDevice(
        fcmTokens,
        {
          notification: notificationPayload,
          data: dataPayload,
        },
        messageOptions
      );

      logger.info("Bildirim gönderme sonucu:", {
        successCount: response.successCount,
        failureCount: response.failureCount,
      });

      const tokensToRemove: string[] = [];
      response.results.forEach((result, index) => {
        const error = result.error;
        if (error) {
          logger.error(`Token'a bildirim gönderilemedi: ${fcmTokens[index]}`, {
            errorCode: error.code,
            errorMessage: error.message,
          });
          if (
            error.code === "messaging/invalid-registration-token" ||
            error.code === "messaging/registration-token-not-registered"
          ) {
            tokensToRemove.push(fcmTokens[index]);
          }
        }
      });

      if (tokensToRemove.length > 0 && userDocRef) {
        const newTokens = fcmTokens.filter(
          (token) => !tokensToRemove.includes(token)
        );
        await userDocRef.update({ fcmTokens: newTokens });
        logger.info(
          `Geçersiz ${tokensToRemove.length} token kullanıcıdan silindi.`,
          { removedTokens: tokensToRemove }
        );
      }
    } catch (error) {
      logger.error(
        "sendNotificationOnNewDonationOffer fonksiyonunda genel hata:",
        error
      );
      return;
    }
    return;
  }
);

// V2 Scheduled Function
export const syncIzmirDonationCenters = onSchedule(
  {
    schedule: "every 24 hours", // Example: "0 3 * * *" for 3 AM daily
    timeZone: "Europe/Istanbul",
    region: "europe-west1", // Specify region
  },
  async (event: ScheduledEvent) => {
    logger.info(
      "Scheduled function (v2): Syncing Izmir Donation Centers to Firestore started.",
      { jobName: event.jobName, scheduleTime: event.scheduleTime }
    );

    const firestoreDb = admin.firestore();

    try {
      const response = await axios.get<ArrayBuffer>(
        IZBB_KAN_MERKEZLERI_API_URL,
        {
          responseType: "arraybuffer",
        }
      );

      if (response.status === 200 && response.data) {
        const jsonData = JSON.parse(
          Buffer.from(response.data).toString("utf8")
        );

        if (
          jsonData &&
          jsonData.onemliyer &&
          Array.isArray(jsonData.onemliyer)
        ) {
          const records: IzmirApiRecord[] = jsonData.onemliyer;
          let batch = firestoreDb.batch();
          let batchCounter = 0;
          const processedCenterIds = new Set<string>();
          let successfulOperations = 0;
          const collectionRef = firestoreDb.collection("donationCenters");

          logger.info(`Processing ${records.length} records from Izmir API.`);

          for (const record of records) {
            try {
              const adi = record.ADI;
              const enlemRaw = record.ENLEM;
              const boylamRaw = record.BOYLAM;

              if (!adi || enlemRaw == null || boylamRaw == null) {
                logger.warn(
                  "Record skipped: ADI, ENLEM, or BOYLAM is missing.",
                  {
                    recordPreview: JSON.stringify(record).substring(0, 100),
                  }
                );
                continue;
              }

              let lat: number | null = null;
              let lon: number | null = null;

              if (
                typeof enlemRaw === "number" &&
                typeof boylamRaw === "number"
              ) {
                lat = enlemRaw;
                lon = boylamRaw;
              } else if (
                typeof enlemRaw === "string" &&
                typeof boylamRaw === "string"
              ) {
                lat = parseFloat(enlemRaw.replace(",", "."));
                lon = parseFloat(boylamRaw.replace(",", "."));
              }

              if (lat == null || lon == null || isNaN(lat) || isNaN(lon)) {
                logger.warn(
                  `Record skipped: Invalid coordinates for ${adi}. ENLEM: ${enlemRaw}, BOYLAM: ${boylamRaw}`
                );
                continue;
              }

              const ilce = record.ILCE;
              let centerIdSource = `${adi}-${
                ilce ?? "bilinmiyor"
              }-${lat.toFixed(4)}-${lon.toFixed(4)}`;
              centerIdSource = centerIdSource
                .toLowerCase()
                .replace(/[^a-z0-9\-_]/g, "");
              if (centerIdSource.length > 100) {
                centerIdSource = centerIdSource.substring(0, 100);
              }
              const md5Hash = CryptoJS.MD5;
              const centerId = md5Hash(centerIdSource).toString();

              if (processedCenterIds.has(centerId)) {
                logger.warn(
                  `Duplicate center ID detected, skipping: ${centerId} for name ${adi}`
                );
                continue;
              }
              processedCenterIds.add(centerId);

              const docRef = collectionRef.doc(centerId);

              const addressParts: string[] = [];
              if (record.MAHALLE) addressParts.push(record.MAHALLE);
              if (record.YOL) addressParts.push(record.YOL);
              if (record.KAPINO) addressParts.push(`No: ${record.KAPINO}`);
              let constructedAddress = addressParts.join(" ").trim();

              if (constructedAddress.length === 0 && record.ACIKLAMA) {
                constructedAddress = record.ACIKLAMA;
              }

              if (
                ilce &&
                !constructedAddress
                  .toLocaleLowerCase("tr-TR")
                  .includes(ilce.toLocaleLowerCase("tr-TR"))
              ) {
                constructedAddress = constructedAddress
                  ? `${constructedAddress}, ${ilce}`
                  : ilce;
              }
              constructedAddress =
                constructedAddress.length > 0
                  ? constructedAddress
                  : ilce ?? "Adres Bilgisi Yok";

              const centerData: Partial<DonationCenterFirestoreData> = {
                id: centerId,
                name: adi,
                address: constructedAddress,
                district: ilce,
                province: "İzmir",
                location: new admin.firestore.GeoPoint(lat, lon),
                isVerified: true,
                source: "izmir_openapi",
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
              };

              const existingDoc = await docRef.get();
              if (!existingDoc.exists) {
                centerData.createdAt =
                  admin.firestore.FieldValue.serverTimestamp();
              }

              batch.set(docRef, centerData, { merge: true });
              batchCounter++;
              successfulOperations++;

              if (batchCounter >= 490) {
                await batch.commit();
                logger.info(`Committed batch of ${batchCounter} records.`);
                batch = firestoreDb.batch();
                batchCounter = 0;
              }
            } catch (e: unknown) {
              const parseError = e as Error;
              logger.error(
                "Error parsing or processing individual API record",
                {
                  errorName: parseError.name,
                  errorMessage: parseError.message,
                  recordPreview: JSON.stringify(record).substring(0, 100),
                }
              );
            }
          }

          if (batchCounter > 0) {
            await batch.commit();
            logger.info(`Committed final batch of ${batchCounter} records.`);
          }
          logger.info(
            `Successfully processed ${records.length} records from API, ${successfulOperations} unique centers were synced to Firestore.`
          );
        } else {
          logger.error(
            "Izmir API response format error: 'onemliyer' key not found or not an array.",
            {
              dataPreview: jsonData
                ? JSON.stringify(jsonData).substring(0, 200)
                : "undefined",
            }
          );
        }
      } else {
        logger.error(
          `Failed to fetch data from Izmir API. Status: ${response.status}`,
          { statusText: response.statusText }
        );
      }
    } catch (e: unknown) {
      const error = e as Error;
      logger.error("Unhandled error in syncIzmirDonationCenters:", {
        errorName: error.name,
        errorMessage: error.message,
        errorObjectString: String(error),
      });
    }
  }
);
