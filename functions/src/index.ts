import {
  onDocumentCreated,
  onDocumentUpdated,
} from "firebase-functions/v2/firestore"; // v2 Firestore trigger
import { onSchedule, ScheduledEvent } from "firebase-functions/v2/scheduler"; // v2 Scheduled function ve ScheduledEvent türü
import * as logger from "firebase-functions/logger"; // v2 logger
import admin = require("firebase-admin");
import axios from "axios";
import CryptoJS = require("crypto-js");

admin.initializeApp();

const db = admin.firestore();
const fcm = admin.messaging();

// Helper function for distance calculation (Haversine formula)
function getDistanceInKm(
  point1: admin.firestore.GeoPoint,
  point2: admin.firestore.GeoPoint
): number {
  const R = 6371; // Radius of the earth in km
  const dLat = deg2rad(point2.latitude - point1.latitude);
  const dLon = deg2rad(point2.longitude - point1.longitude);
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(deg2rad(point1.latitude)) *
      Math.cos(deg2rad(point2.latitude)) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  const d = R * c; // Distance in km
  return d;
}

function deg2rad(deg: number): number {
  return deg * (Math.PI / 180);
}

// Blood compatibility check (simplified)
// Based on lib/core/utils/blood_compatibility.dart
function getCompatibleRecipientGroups(donorBloodType: string): string[] {
  switch (donorBloodType) {
    case "O-":
      return ["O-", "O+", "A-", "A+", "B-", "B+", "AB-", "AB+"];
    case "O+":
      return ["O+", "A+", "B+", "AB+"];
    case "A-":
      return ["A-", "A+", "AB-", "AB+"];
    case "A+":
      return ["A+", "AB+"];
    case "B-":
      return ["B-", "B+", "AB-", "AB+"];
    case "B+":
      return ["B+", "AB+"];
    case "AB-":
      return ["AB-", "AB+"];
    case "AB+":
      return ["AB+"];
    default:
      return [];
  }
}

function canDonateTo(
  donorBloodType: string | undefined,
  recipientBloodType: string | undefined
): boolean {
  if (!donorBloodType || !recipientBloodType) return false;
  const compatibleGroups = getCompatibleRecipientGroups(donorBloodType);
  return compatibleGroups.includes(recipientBloodType);
}

// Define interfaces for User data if not already present or enhance them
interface UserProfileData {
  bloodType?: string;
  lastDonationDate?: admin.firestore.Timestamp;
  isAvailableToDonate?: boolean;
  fullName?: string;
  email?: string; // Genellikle Firebase Auth üzerinden gelir ama profil için de tutulabilir
  phoneNumber?: string;
  photoUrl?: string;
  role?: "individual" | "hospital";
  donationCount?: number;
  medicalInfo?: string; // Bireysel kullanıcılar için
  hospitalName?: string; // Hastane kullanıcıları için
  hospitalAddress?: string; // Hastane kullanıcıları için
  hospitalContact?: string; // Hastane kullanıcıları için
  isHospitalVerified?: boolean; // Hastane kullanıcıları için
  createdAt?: admin.firestore.Timestamp;
  updatedAt?: admin.firestore.Timestamp;
  // Diğer potansiyel profil alanları: dateOfBirth, gender, address vb.
}

interface UserSettings {
  notificationsEnabled?: boolean;
  notifyForNearbyRequests?: boolean; // Yakındaki talepler için bildirim ayarı
  privacyLevel?: "public" | "private"; // Profil gizlilik seviyesi
  locationSharingEnabled?: boolean; // Konum paylaşım ayarı
  language?: string; // Uygulama dili tercihi (örn: "tr", "en")
  theme?: "light" | "dark" | "system"; // Uygulama tema tercihi
  eligibleForDonationNotification?: boolean; // Bağışa uygunluk bildirimi için ayar
  // Diğer potansiyel ayarlar: notificationSound, emailNotificationsEnabled, smsNotificationsEnabled vb.
}

interface UserDocument {
  id?: string; // User ID
  fcmTokens?: string[];
  profileData?: UserProfileData;
  settings?: UserSettings;
  lastKnownLocation?: admin.firestore.GeoPoint;
  // ... other user fields
}

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

// V2 Firestore Trigger for accepted donation offers
export const sendNotificationToDonorOnOfferAccepted = onDocumentUpdated(
  {
    document: "donationResponses/{responseId}",
    region: "europe-west1",
  },
  async (event) => {
    if (!event.data) {
      logger.error(
        "Bağış teklifi kabul trigger'ı (güncelleme) çalıştı ama event.data yok.",
        { eventId: event.id }
      );
      return;
    }

    const beforeData = event.data.before.data();
    const afterData = event.data.after.data();
    const responseId = event.params.responseId;

    logger.info(
      `Bağış teklifi güncelleme trigger'ı çalıştı. Response ID: ${responseId}`,
      { beforeData, afterData }
    );

    if (!beforeData || !afterData) {
      logger.error(
        "Teklifin önceki veya sonraki verisi (beforeData/afterData) bulunamadı."
      );
      return;
    }

    // Check if the status changed to 'accepted'
    if (beforeData.status !== "accepted" && afterData.status === "accepted") {
      const donorId = afterData.donorId as string | undefined;
      const requestId = afterData.requestId as string | undefined;
      // const donorName = afterData.donorName as string | undefined; // Already available if needed for body

      if (!donorId) {
        logger.error("Kabul edilen teklif verisinde 'donorId' eksik.", {
          afterData,
        });
        return;
      }
      if (!requestId) {
        logger.error("Kabul edilen teklif verisinde 'requestId' eksik.", {
          afterData,
        });
        return;
      }

      try {
        const donorUserDocRef = db.collection("users").doc(donorId);
        const donorUserDocSnap = await donorUserDocRef.get();

        if (!donorUserDocSnap.exists) {
          logger.error("Teklifi kabul edilen bağışçı bulunamadı:", donorId);
          return;
        }

        const donorUserData = donorUserDocSnap.data() as UserDocument;
        const fcmTokens = donorUserData?.fcmTokens;

        if (!fcmTokens || fcmTokens.length === 0) {
          logger.warn(
            `Teklifi kabul edilen bağışçının (${donorId}) FCM token'ı bulunamadı veya boş.`
          );
          return;
        }

        const requestDocSnap = await db
          .collection("bloodRequests")
          .doc(requestId)
          .get();
        const requestTitle = requestDocSnap.exists
          ? (requestDocSnap.data()?.title as string | undefined) ||
            "ilgili kan talebi"
          : "ilgili kan talebi";
        const requestCreatorName = requestDocSnap.exists
          ? (requestDocSnap.data()?.creatorName as string | undefined)
          : "";

        const notificationPayload: admin.messaging.NotificationMessagePayload =
          {
            title: "Kan Bağışı Teklifiniz Kabul Edildi!",
            body: `${
              requestCreatorName
                ? requestCreatorName + " adlı kullanıcının "
                : ""
            }"${requestTitle}" için yaptığınız kan bağışı teklifi kabul edildi. Lütfen detaylar için iletişime geçin.`,
          };

        const dataPayload: { [key: string]: string } = {
          type: "donation_offer_accepted",
          requestId: requestId,
          responseId: responseId,
          routePath: `/myAcceptedOffers/${responseId}`, // Örnek yönlendirme
          clickTimestamp: Date.now().toString(),
        };

        const messageOptions: admin.messaging.MessagingOptions = {
          priority: "high",
        };

        logger.info(
          `Teklifi kabul edilen bağışçıya (${donorId}) bildirim gönderiliyor. Token sayısı: ${fcmTokens.length}`,
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

        logger.info("Kabul bildirimi gönderme sonucu:", {
          successCount: response.successCount,
          failureCount: response.failureCount,
        });

        const tokensToRemove: string[] = [];
        response.results.forEach((result, index) => {
          const error = result.error;
          if (error) {
            logger.error(
              `Token'a kabul bildirimi gönderilemedi: ${fcmTokens[index]}`,
              {
                errorCode: error.code,
                errorMessage: error.message,
              }
            );
            if (
              error.code === "messaging/invalid-registration-token" ||
              error.code === "messaging/registration-token-not-registered"
            ) {
              tokensToRemove.push(fcmTokens[index]);
            }
          }
        });

        if (tokensToRemove.length > 0 && donorUserDocRef) {
          const newTokens = fcmTokens.filter(
            (token) => !tokensToRemove.includes(token)
          );
          await donorUserDocRef.update({ fcmTokens: newTokens });
          logger.info(
            `Geçersiz ${tokensToRemove.length} token kabul edilen bağışçıdan silindi.`,
            { removedTokens: tokensToRemove }
          );
        }
      } catch (error) {
        logger.error(
          "sendNotificationToDonorOnOfferAccepted fonksiyonunda genel hata:",
          error
        );
      }
    } else {
      logger.info(
        `Teklif durumu 'accepted' olarak değişmedi veya zaten 'accepted' idi. Response ID: ${responseId}`,
        { beforeStatus: beforeData.status, afterStatus: afterData.status }
      );
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

// V2 Firestore Trigger for new blood requests
export const notifyUsersOfNearbyRequests = onDocumentCreated(
  {
    document: "bloodRequests/{requestId}",
    region: "europe-west1",
  },
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
      logger.error("Yeni kan talebi trigger'ı çalıştı ama snapshot yok.", {
        eventId: event.id,
      });
      return;
    }

    const requestData = snapshot.data();
    const requestId = snapshot.id;
    logger.info(`Yeni kan talebi trigger'ı çalıştı. Request ID: ${requestId}`, {
      requestData,
    });

    if (!requestData) {
      logger.error("Talep verisi (requestData) bulunamadı.");
      return;
    }

    const requestBloodType = requestData.bloodType as string | undefined;
    const requestLocation = requestData.location as
      | admin.firestore.GeoPoint
      | undefined;
    const requestTitle = (requestData.title as string) || "Acil Kan İhtiyacı"; // Now used
    const requestCreatorId = requestData.creatorId as string | undefined;

    if (!requestBloodType || !requestLocation) {
      logger.error("Talep verisinde 'bloodType' veya 'location' eksik.", {
        requestData,
      });
      return;
    }

    const usersSnapshot = await db.collection("users").get();
    if (usersSnapshot.empty) {
      logger.info("Bildirim gönderilecek kullanıcı bulunamadı.");
      return;
    }

    const nearbyRadiusKm = 20; // 20 km yarıçap, ayarlanabilir.
    const notificationPromises: Promise<
      string | admin.firestore.WriteResult | null
    >[] = [];

    for (const userDoc of usersSnapshot.docs) {
      const userData = userDoc.data() as UserDocument;
      const userId = userDoc.id;

      // Skip the user who created the request
      if (userId === requestCreatorId) {
        continue;
      }

      const userProfile = userData.profileData;
      const userSettings = userData.settings;
      const userFcmTokens = userData.fcmTokens;
      const userLocation = userData.lastKnownLocation;

      if (
        userProfile?.bloodType &&
        userSettings?.notificationsEnabled &&
        userSettings?.notifyForNearbyRequests !== false && // Default to true if undefined
        userProfile?.isAvailableToDonate !== false && // Default to true if undefined
        userFcmTokens &&
        userFcmTokens.length > 0 &&
        userLocation
      ) {
        if (canDonateTo(userProfile.bloodType, requestBloodType)) {
          const distance = getDistanceInKm(userLocation, requestLocation);
          if (distance <= nearbyRadiusKm) {
            logger.info(
              `Kullanıcı ${userId} (${
                userProfile.bloodType
              }) talep için uygun ve ${distance.toFixed(2)}km yakınlıkta.`
            );
            const notificationPayload: admin.messaging.NotificationMessagePayload =
              {
                title: "Yakınınızda Kan İhtiyacı Var!",
                body: `${userProfile.bloodType} kan grubunuzla uyumlu '${requestTitle}' talebi yakınınızda oluşturuldu.`,
              };
            const dataPayload = {
              type: "nearby_blood_request",
              requestId: requestId,
              routePath: `/bloodRequestDetails/${requestId}`, // Örnek yönlendirme yolu
              clickTimestamp: Date.now().toString(),
            };

            const message: admin.messaging.Message = {
              notification: notificationPayload,
              data: dataPayload,
              token: "", // Will be set per token
            };

            userFcmTokens.forEach((token) => {
              const singleMessage = { ...message, token: token };
              notificationPromises.push(
                fcm.send(singleMessage).catch((error) => {
                  logger.error(`Token'a bildirim gönderilemedi: ${token}`, {
                    errorCode: error.code,
                    errorMessage: error.message,
                  });
                  if (
                    error.code === "messaging/invalid-registration-token" ||
                    error.code === "messaging/registration-token-not-registered"
                  ) {
                    const userRef = db.collection("users").doc(userId);
                    return userRef
                      .update({
                        fcmTokens:
                          admin.firestore.FieldValue.arrayRemove(token),
                      })
                      .catch((updateError) => {
                        logger.error(
                          `Token güncelleme hatası kullanıcı ${userId} için token ${token}`,
                          { error: updateError }
                        );
                        return null; // If update fails, resolve outer promise to null
                      });
                  }
                  return null; // If error code doesn't match for token removal
                })
              );
            });
          }
        }
      }
    }
    if (notificationPromises.length > 0) {
      await Promise.all(notificationPromises);
      logger.info(
        `${notificationPromises.length} adet "yakındaki talep" bildirimi gönderme işlemi denendi.`
      );
    } else {
      logger.info(
        "Yakındaki talep için uygun kullanıcıya bildirim gönderilmedi."
      );
    }
    return;
  }
);

// V2 Scheduled Function for donation eligibility
export const notifyUsersForDonationEligibility = onSchedule(
  {
    schedule: "every 24 hours", // "0 9 * * *" for 9 AM daily
    timeZone: "Europe/Istanbul",
    region: "europe-west1",
  },
  async (event: ScheduledEvent) => {
    logger.info("Zamanlanmış fonksiyon: Bağış uygunluk kontrolü başladı.", {
      jobName: event.jobName,
      scheduleTime: event.scheduleTime,
    });

    const usersSnapshot = await db.collection("users").get();
    if (usersSnapshot.empty) {
      logger.info("Uygunluk kontrolü için kullanıcı bulunamadı.");
      return;
    }

    const eligibilityPeriodDays = 56;
    const notificationPromises: Promise<
      string | admin.firestore.WriteResult | null
    >[] = [];

    for (const userDoc of usersSnapshot.docs) {
      const userData = userDoc.data() as UserDocument;
      const userId = userDoc.id;
      const userProfile = userData.profileData;
      const userSettings = userData.settings;
      const userFcmTokens = userData.fcmTokens;

      if (
        userProfile?.lastDonationDate &&
        userSettings?.notificationsEnabled &&
        userFcmTokens &&
        userFcmTokens.length > 0
      ) {
        const lastDonationTime = userProfile.lastDonationDate.toMillis();
        const eligibilityTime =
          lastDonationTime + eligibilityPeriodDays * 24 * 60 * 60 * 1000;
        const now = Date.now();

        if (
          now >= eligibilityTime &&
          (userProfile.isAvailableToDonate === false ||
            userProfile.isAvailableToDonate === undefined)
        ) {
          logger.info(
            `Kullanıcı ${userId} tekrar bağış yapabilir. Son bağış: ${userProfile.lastDonationDate
              .toDate()
              .toISOString()}`
          );

          const notificationPayload: admin.messaging.NotificationMessagePayload =
            {
              title: "Tekrar Kan Bağışında Bulunabilirsiniz!",
              body: "Kan bağışı için uygunluk süreniz doldu. Haydi, hayat kurtarmaya devam edin!",
            };
          const dataPayload = {
            type: "donation_eligibility",
            routePath: "/profile", // Örnek yönlendirme
            clickTimestamp: Date.now().toString(),
          };

          const message: admin.messaging.Message = {
            notification: notificationPayload,
            data: dataPayload,
            token: "", // Will be set per token
          };

          userFcmTokens.forEach((token) => {
            const singleMessage = { ...message, token: token };
            notificationPromises.push(
              fcm
                .send(singleMessage)
                .then(async (response) => {
                  if (userProfile.isAvailableToDonate === false) {
                    await db
                      .collection("users")
                      .doc(userId)
                      .update({ "profileData.isAvailableToDonate": true });
                    logger.info(
                      `Kullanıcı ${userId} durumu 'bağış yapabilir' olarak güncellendi.`
                    );
                  }
                  return response; // response is messageId (string)
                })
                .catch((error) => {
                  logger.error(
                    `Token'a uygunluk bildirimi gönderilemedi: ${token}`,
                    {
                      errorCode: error.code,
                      errorMessage: error.message,
                    }
                  );
                  if (
                    error.code === "messaging/invalid-registration-token" ||
                    error.code === "messaging/registration-token-not-registered"
                  ) {
                    const userRef = db.collection("users").doc(userId);
                    return userRef
                      .update({
                        fcmTokens:
                          admin.firestore.FieldValue.arrayRemove(token),
                      })
                      .catch((updateError) => {
                        logger.error(
                          `Token güncelleme hatası kullanıcı ${userId} için token ${token}`,
                          { error: updateError }
                        );
                        return null; // If update fails, resolve outer promise to null
                      });
                  }
                  return null; // If error code doesn't match for token removal
                })
            );
          });
        }
      }
    }
    if (notificationPromises.length > 0) {
      await Promise.all(notificationPromises);
      logger.info(
        `${notificationPromises.length} adet "bağış uygunluk" bildirimi gönderme işlemi denendi.`
      );
    } else {
      logger.info(
        "Bağış uygunluğu için bildirim gönderilecek kullanıcı bulunamadı/uygun değil."
      );
    }
    return;
  }
);
