import graphviz
import re

dbml_content = """
// KanBul Database Model (Firestore için DBML)

Table USERS {
  userId varchar [pk, note: "Kullanıcı benzersiz kimliği (Firebase Auth UID)"]
  email varchar [not null, unique, note: "Kullanıcı e-posta adresi"]
  fullName varchar [not null, note: "Kullanıcının tam adı"]
  phoneNumber varchar [null, note: "Kullanıcının telefon numarası"]
  role varchar [not null, note: "'individual' veya 'hospital' rolü"]
  photoUrl varchar [null, note: "Profil fotoğrafı URL'si"]
  createdAt timestamp [not null, note: "Hesap oluşturulma tarihi"]
  updatedAt timestamp [not null, note: "Son güncelleme tarihi"]
  settings Map [not null, note: "Gömülü Ayarlar {notificationsEnabled: bool, privacyLevel: string, locationSharingEnabled: bool}"]
  profileData Map [not null, note: "Gömülü, role göre değişen profil bilgileri {bloodType, lastDonationDate, hospitalName, etc.}"]
  lastKnownLocation Map [null, note: "Gömülü Son Konum {latitude: number, longitude: number, timestamp: timestamp}"]
}

Table BLOOD_REQUESTS {
  requestId varchar [pk, note: "Talep benzersiz kimliği (Firestore Auto-ID)"]
  creatorId varchar [not null, ref: > USERS.userId, note: "Talebi oluşturan kullanıcının ID'si"]
  creatorName varchar [null, note: "Oluşturanın Adı (Denormalized)"]
  creatorRole varchar [null, note: "'individual' veya 'hospital' (Denormalized)"]
  bloodType varchar [not null, note: "İhtiyaç duyulan kan grubu"]
  status varchar [not null, note: "'active', 'fulfilled', 'canceled'"]
  location GeoPoint [not null, note: "Talebin konumu (Firestore GeoPoint)"]
  title varchar [not null, note: "Talep başlığı"]
  description varchar [not null, note: "Talep açıklaması"]
  unitsNeeded int [not null, note: "İhtiyaç duyulan kan ünitesi sayısı"]
  urgencyLevel int [not null, note: "Aciliyet seviyesi"]
  responseCount int [not null, default: 0, note: "Yanıt sayısı (Denormalized)"]
  createdAt timestamp [not null, note: "Oluşturulma tarihi"]
  updatedAt timestamp [not null, note: "Son güncelleme tarihi"]
  patientInfo varchar [null, note: "Hasta bilgileri (Gizliliğe dikkat!)"]
  hospitalName varchar [null, note: "Hastane adı (Denormalized, hastane oluşturduysa)"]
}

Table DONATIONS {
  donationId varchar [pk, note: "Bağış yanıtı benzersiz kimliği (Firestore Auto-ID)"]
  donorId varchar [not null, ref: > USERS.userId, note: "Bağışçının ID'si (Rolü 'individual' olmalı)"]
  donorName varchar [null, note: "Bağışçının adı (Denormalized)"]
  donorBloodType varchar [null, note: "Bağışçının kan grubu (Denormalized)"]
  donorPhotoUrl varchar [null, note: "Bağışçının profil fotoğrafı URL'si (Denormalized)"]
  requestId varchar [not null, ref: > BLOOD_REQUESTS.requestId, note: "İlgili kan talebi ID'si"]
  requestCreatorId varchar [not null, ref: > USERS.userId, note: "Talebi oluşturan kullanıcının ID'si (Denormalized)"]
  status varchar [not null, note: "'pending', 'accepted', 'rejected', 'completed'"]
  respondedAt timestamp [not null, note: "Yanıt verilen tarih"]
  scheduledDate timestamp [null, note: "Planlanmış bağış tarihi"]
  completedDate timestamp [null, note: "Tamamlanma tarihi"]
  message varchar [null, note: "Bağışçının mesajı"]
  createdAt timestamp [not null, note: "Oluşturulma tarihi"]
  updatedAt timestamp [not null, note: "Son güncelleme tarihi"]
  donationLocation GeoPoint [null, note: "Bağışın yapıldığı konum (Opsiyonel)"]
}

Table BADGES {
  badgeId varchar [pk, note: "Rozet benzersiz kimliği"]
  name varchar [not null, note: "Rozet adı"]
  description varchar [not null, note: "Rozet açıklaması"]
  imageUrl varchar [null, note: "Rozet görsel URL'si"]
  criteria varchar [not null, note: "Rozet kazanma kriteri, örn: 'donationCount >= 5'"]
  badgeType varchar [not null, note: "'donation', 'community', vs."]
}

Table USER_BADGES {
  // Alt koleksiyon: users/{userId}/badges/{badgeId}
  badgeId varchar [pk, ref: > BADGES.badgeId, note: "Badge ID'si (Döküman ID'si)"]
  earningDate timestamp [not null, note: "Rozet kazanma tarihi"]
  // userId FK olarak belirtmeye gerek yok, parent'tan gelir.
}

// İlişkiler (Ref ile belirtildi, ek olarak notlar)
Note N_User_Requests { "Bir kullanıcı (USERS) birden fazla talep (BLOOD_REQUESTS) oluşturabilir (1:N)." }
Note N_User_Donations { "Bir kullanıcı (USERS - bireysel) birden fazla bağış yanıtı (DONATIONS) verebilir (1:N)." }
Note N_Request_Donations { "Bir talep (BLOOD_REQUESTS) birden fazla bağış yanıtı (DONATIONS) alabilir (1:N)." }
Note N_User_Badges { "Bir kullanıcı (USERS) birden fazla rozet (USER_BADGES) kazanabilir (1:N, Alt Koleksiyon)." }
Note N_Badge_UserBadges { "Bir rozet (BADGES) birden fazla kullanıcı tarafından (USER_BADGES) kazanılabilir (1:N)." }
"""

def parse_dbml(dbml):
    """Parses DBML content to extract tables, columns, relationships, and notes."""
    tables = {}
    relationships = []
    notes = {}
    current_table = None

    table_pattern = re.compile(r"Table\s+(\w+)\s*{")
    column_pattern = re.compile(r"\s*(\w+)\s+([\w<>]+(?:\[\])?)\s*(\[(.*)\])?") # Capture constraints content
    ref_pattern = re.compile(r"ref:\s*([<>])\s*(\w+)\.(\w+)") # Capture direction too
    subcollection_pattern = re.compile(r"//\s*Alt koleksiyon:\s*(\w+)/\{\w+\}/(\w+)/\{\w+\}")
    note_pattern = re.compile(r"Note\s+(\w+)\s*{\s*\"(.*)\"\s*}")

    lines = dbml.strip().split('\n')
    is_subcollection = False
    parent_collection = None

    for i, line in enumerate(lines):
        line = line.strip()

        # Skip empty lines and standard comments
        if not line or (line.startswith("//") and not "Alt koleksiyon:" in line):
            continue

        # Check for subcollection comment
        subcollection_match = subcollection_pattern.search(line)
        if subcollection_match:
            parent_collection = subcollection_match.group(1)
            # The next table definition will be the subcollection
            is_subcollection = True
            continue # Process next line for table definition

        # Check for Note definition
        note_match = note_pattern.match(line)
        if note_match:
            note_name = note_match.group(1)
            note_content = note_match.group(2)
            notes[note_name] = note_content
            continue

        # Check for Table definition
        table_match = table_pattern.match(line)
        if table_match:
            current_table = table_match.group(1)
            tables[current_table] = {
                'columns': [],
                'is_subcollection': is_subcollection,
                'parent': parent_collection
            }
            # Reset subcollection flags for the next potential table
            is_subcollection = False
            parent_collection = None
            continue

        # End of table definition
        if line == "}":
            current_table = None
            continue

        # Process columns within a table
        if current_table:
            column_match = column_pattern.match(line)
            if column_match:
                col_name, col_type, _, constraints_content = column_match.groups()
                constraints = {'pk': False, 'fk': False, 'nn': False, 'uq': False, 'note': None}
                col_note = None

                if constraints_content:
                    # Extract note first if present
                    note_extract_match = re.search(r'note:\s*\"(.*?)\"', constraints_content)
                    if note_extract_match:
                        col_note = note_extract_match.group(1)
                        # Remove note from constraints_content for easier parsing of other constraints
                        constraints_content = constraints_content.replace(note_extract_match.group(0), '').strip(', ')

                    parts = [p.strip() for p in constraints_content.split(',') if p.strip()]
                    for part in parts:
                        if part == 'pk':
                            constraints['pk'] = True
                        elif part == 'not null':
                            constraints['nn'] = True
                        elif part == 'unique':
                            constraints['uq'] = True
                        elif part.startswith('ref:'):
                            constraints['fk'] = True
                            ref_match = ref_pattern.search(part)
                            if ref_match:
                                direction, ref_table, ref_col = ref_match.groups()
                                # Determine relationship type based on direction symbol
                                # '>' means one-to-many (from current table to ref_table)
                                # '<' means many-to-one (from ref_table to current table)
                                # '-' means one-to-one (not used here)
                                rel_type = '1:N' if direction == '>' else 'N:1' # Simplified assumption

                                relationships.append({
                                    'from_table': current_table,
                                    'from_col': col_name,
                                    'to_table': ref_table,
                                    'to_col': ref_col,
                                    'type': rel_type
                                })

                tables[current_table]['columns'].append({
                    'name': col_name,
                    'type': col_type,
                    'constraints': constraints,
                    'note': col_note
                })

    return tables, relationships, notes

def generate_diagram(tables, relationships, notes, filename="firestore_schema_detailed"):
    """Generates a detailed Graphviz diagram from parsed DBML data."""
    dot = graphviz.Digraph('FirestoreDB', comment='KanBul Firestore Schema Detailed', format='png')
    dot.attr(rankdir='LR', splines='ortho', nodesep='0.8', ranksep='1.2') # Adjust spacing
    dot.attr('node', shape='plain', fontname='Arial', fontsize='10')
    dot.attr('edge', fontname='Arial', fontsize='9', color='#555555') # Default edge style
    dot.attr(label=f'KanBul Firestore Schema\nGenerated: {datetime.now().strftime("%Y-%m-%d %H:%M")}', labelloc='t', fontsize='14')

    # Define nodes (tables) with detailed columns
    for table_name, table_data in tables.items():
        label = f'<TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0" CELLPADDING="4" BGCOLOR="#F8F8F8">'
        # Table Header
        label += f'<TR><TD COLSPAN="3" BGCOLOR="#4477AA"><FONT COLOR="white"><B>{table_name}</B></FONT></TD></TR>'
        # Subcollection Indicator
        if table_data.get('is_subcollection'):
             label += f'<TR><TD COLSPAN="3" BGCOLOR="#E0E0E0"><I>(Subcollection of {table_data["parent"]})</I></TD></TR>'
        # Column Headers
        label += f'<TR><TD ALIGN="LEFT"><B>Column</B></TD><TD ALIGN="LEFT"><B>Type</B></TD><TD ALIGN="LEFT"><B>Details</B></TD></TR>'

        # Columns
        for col in table_data['columns']:
            constraints = col['constraints']
            col_name_display = col['name']
            details = []

            if constraints['pk']:
                col_name_display = f'<B>{col_name_display}</B>'
                details.append('<FONT COLOR="#B8860B">PK</FONT>') # Gold color for PK
            if constraints['fk']:
                 details.append('<FONT COLOR="#4682B4">FK</FONT>') # SteelBlue for FK
            if constraints['nn']:
                details.append('<FONT COLOR="#DC143C">NN</FONT>') # Crimson for NN
            if constraints['uq']:
                details.append('<FONT COLOR="#9932CC">UQ</FONT>') # DarkOrchid for UQ
            if col['note']:
                 # Add note as tooltip (hover text) or directly if short
                 # Tooltips are better for avoiding clutter
                 # Graphviz HTML labels support a 'TOOLTIP' attribute on TD
                 # However, direct rendering might not support it well everywhere.
                 # Let's add it to the details column for now.
                 details.append(f'<I><FONT COLOR="grey50">Note: {col["note"][:30]}{"..." if len(col["note"])>30 else ""}</FONT></I>')


            details_str = '<BR/>'.join(details) # Use HTML line breaks

            label += f'<TR><TD ALIGN="LEFT" VALIGN="TOP">{col_name_display}</TD>'
            label += f'<TD ALIGN="LEFT" VALIGN="TOP">{col["type"]}</TD>'
            label += f'<TD ALIGN="LEFT" VALIGN="TOP">{details_str}</TD></TR>'

        label += '</TABLE>'
        dot.node(table_name, label=f'<{label}>') # Use < > for HTML-like labels

    # Define edges (relationships) from 'ref'
    for rel in relationships:
         # Determine arrowhead/tail based on relationship type if available
         # Defaulting to 1:N representation (crow foot at 'many' side)
         from_node = f"{rel['from_table']}"
         to_node = f"{rel['to_table']}"
         edge_label = f"  {rel['from_col']} -> {rel['to_col']}  " # Add spaces for padding

         # Customize edge appearance for FKs
         dot.edge(from_node, to_node,
                  label=edge_label,
                  arrowhead='crow', # 'Many' side points to the table containing the FK
                  arrowtail='none',
                  dir='forward',
                  color='#4682B4', # SteelBlue for FK relations
                  fontcolor='#4682B4',
                  penwidth='1.5')


    # Define subcollection relationships explicitly
    for table_name, table_data in tables.items():
        if table_data.get('is_subcollection') and table_data.get('parent'):
             parent_node = table_data['parent']
             sub_node = table_name
             # Draw a distinct edge for subcollection hierarchy
             dot.edge(parent_node, sub_node,
                      style='dashed',
                      arrowhead='odot', # Small circle at child end
                      arrowtail='none',
                      dir='forward',
                      label=' contains\n (subcollection)',
                      color='grey60',
                      fontcolor='grey40',
                      fontsize='8',
                      constraint='true') # Ensure it influences layout

    # Add Notes as separate nodes
    if notes:
        with dot.subgraph(name='cluster_notes') as c:
            c.attr(label='Relationship Notes', style='filled', color='lightgrey', fontname='Arial', fontsize='12')
            c.attr('node', shape='note', style='filled', fillcolor='#FFFFE0', fontname='Arial', fontsize='9') # Light yellow notes
            for note_name, note_content in notes.items():
                # Wrap long text
                wrapped_content = '\n'.join(textwrap.wrap(note_content, width=40))
                c.node(note_name, label=f"{note_name}:\n{wrapped_content}")
    # Render the diagram
    try:
        dot.render(filename, view=False, cleanup=True)
        print(f"Detailed diagram saved as {filename}.png")
    except graphviz.backend.execute.CalledProcessError as e:
        print(f"Detailed diagram saved as {filename}.png")
    except graphviz.backend.execute.CalledProcessError as e:
        print(f"Error rendering diagram: {e}")
        print("Please ensure Graphviz is installed and in your system's PATH.")
        print("Installation instructions: https://graphviz.org/download/")
    except ImportError as e:
         print(f"Missing Python library: {e}. Please install it (e.g., pip install {e.name})")
    except Exception as e:
         print(f"An unexpected error occurred: {e}")


if __name__ == "__main__":
    # Import necessary libraries here if not already imported globally
    from datetime import datetime
    import textwrap

    parsed_tables, parsed_relationships, parsed_notes = parse_dbml(dbml_content)
    generate_diagram(parsed_tables, parsed_relationships, parsed_notes, filename="kanbul_firestore_schema_detailed")
