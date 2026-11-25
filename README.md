# OliNabilAza Planner — JSP Version (Quiz 2)

A student planner for managing **courses (with weekly schedule), tasks, and lecture notes**, rebuilt from our Laravel midterm project using **JSP (Jakarta Server Pages) + JDBC + MySQL**.

- **Live website:**
- **Demo account:** `guest@gmail.com` / `pass12345`
- **Members:** Nabila Zalfaa Putri Hamid (5025251089), Mumtaz Hanumi Fayazida (5025251091), Caroline Alverina (5025251097)

## Tech stack
| Part | Technology |
|------|------------|
| Pages | JSP 3.1 (scriptlets + static includes) |
| Server | Apache Tomcat 10.1, Java 21 |
| Database | MySQL / MariaDB (local XAMPP) · TiDB Cloud Starter, MySQL-compatible (hosting) |
| Hosting | Render (Docker, free web service) |

## Features
Register, login (remember me), logout, dashboard (statistics, progress, deadlines), course CRUD, **weekly schedule (new)**, task CRUD, mark task done, task search & filter, notes CRUD & search, edit profile, change password.

## Folder structure
```
olinabilaza-planner-jsp/
├── Dockerfile               ← used by Render to build Tomcat + the website
├── database/schema.sql      ← database structure (documentation / manual import)
└── web/                     ← the website (copied to Tomcat as is, no build step)
    ├── *.jsp                ← one file per page / action
    ├── css/ fonts/ favicon.svg
    └── WEB-INF/
        ├── web.xml
        └── includes/        ← init.jspf (DB + helpers), auth.jspf, header.jspf, footer.jspf
```

## Run locally (short version)
1. Install **JDK 21**, **Apache Tomcat 10.1**, and **XAMPP** (MySQL).
2. Download `mysql-connector-j-8.4.0.jar` and put it into `apache-tomcat-10.1.x/lib/`.
3. Start MySQL in XAMPP.
4. Create `apache-tomcat-10.1.x/conf/Catalina/localhost/planner.xml`:
   ```xml
   <Context docBase="C:/path/to/olinabilaza-planner-jsp/web" reloadable="true" />
   ```
5. Run `bin/startup.bat` (Windows) or `bin/startup.sh`, then open http://localhost:8080/olinabilaza/
   Tables and the demo account are created automatically on the first visit.

## Environment variables (hosting)
| Name | Example |
|------|---------|
| `DB_URL`  | `jdbc:mysql://gateway01.ap-southeast-1.prod.aws.tidbcloud.com:4000/olinabilaza_planner?sslMode=VERIFY_IDENTITY&createDatabaseIfNotExist=true` |
| `DB_USER` | `xxxxxxxx.root` |
| `DB_PASS` | your database password |
| `PORT`    | `8080` |

Without these variables the app uses the local default `jdbc:mysql://localhost:3306/olinabilaza_planner`, user `root`, empty password (XAMPP).
