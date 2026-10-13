------------------------------------------------------------------------
-- 0. (OPTIONNEL) NETTOYAGE PREALABLE
------------------------------------------------------------------------

-- DROP TABLE BRZ_BANKING_IMPORT PURGE;
-- DROP TABLE SLV_BANKING_DATA PURGE;
-- DROP TABLE DIM_DATE PURGE;
-- DROP TABLE DIM_CUSTOMER PURGE;
-- DROP TABLE DIM_PRODUCT PURGE;
-- DROP TABLE FACT_TRANSACTIONS PURGE;
-- DROP TABLE ALERTS_LOG PURGE;

-- DROP SEQUENCE SEQ_DIM_CUSTOMER;
-- DROP SEQUENCE SEQ_DIM_PRODUCT;
-- DROP SEQUENCE SEQ_FACT_TRANSACTIONS;

-- DROP PACKAGE PKG_DATA_CLEANING;
-- DROP PACKAGE PKG_BUSINESS_LOGIC;
-- DROP TRIGGER TRG_DETECT_CRITICAL_RISK;

------------------------------------------------------------------------
-- 1. ARCHITECTURE MEDALLION - TABLES BRONZE / SILVER / GOLD
------------------------------------------------------------------------

-----------------------------
-- 1.1 TABLE BRONZE
--     Copie brute du CSV
--     Toutes les colonnes en VARCHAR2
-----------------------------
CREATE TABLE BRZ_BANKING_IMPORT (
    CUSTOMER_ID                       VARCHAR2(4000),
    FIRST_NAME                        VARCHAR2(4000),
    LAST_NAME                         VARCHAR2(4000),
    AGE                               VARCHAR2(4000),
    GENDER                            VARCHAR2(4000),
    ADDRESS                           VARCHAR2(4000),
    CITY                              VARCHAR2(4000),
    CONTACT_NUMBER                    VARCHAR2(4000),
    EMAIL                             VARCHAR2(4000),
    ACCOUNT_TYPE                      VARCHAR2(4000),
    ACCOUNT_BALANCE                   VARCHAR2(4000),
    DATE_OF_ACCOUNT_OPENING           VARCHAR2(4000),
    LAST_TRANSACTION_DATE             VARCHAR2(4000),
    TRANSACTIONID                     VARCHAR2(4000),
    TRANSACTION_DATE                  VARCHAR2(4000),
    TRANSACTION_TYPE                  VARCHAR2(4000),
    TRANSACTION_AMOUNT                VARCHAR2(4000),
    ACCOUNT_BALANCE_AFTER_TRANSACTION VARCHAR2(4000),
    BRANCH_ID                         VARCHAR2(4000),
    LOAN_ID                           VARCHAR2(4000),
    LOAN_AMOUNT                       VARCHAR2(4000),
    LOAN_TYPE                         VARCHAR2(4000),
    INTEREST_RATE                     VARCHAR2(4000),
    LOAN_TERM                         VARCHAR2(4000),
    APPROVAL_REJECTION_DATE           VARCHAR2(4000),
    LOAN_STATUS                       VARCHAR2(4000),
    CARDID                            VARCHAR2(4000),
    CARD_TYPE                         VARCHAR2(4000),
    CREDIT_LIMIT                      VARCHAR2(4000),
    CREDIT_CARD_BALANCE               VARCHAR2(4000),
    MINIMUM_PAYMENT_DUE               VARCHAR2(4000),
    PAYMENT_DUE_DATE                  VARCHAR2(4000),
    LAST_CREDIT_CARD_PAYMENT_DATE     VARCHAR2(4000),
    REWARDS_POINTS                    VARCHAR2(4000),
    FEEDBACK_ID                       VARCHAR2(4000),
    FEEDBACK_DATE                     VARCHAR2(4000),
    FEEDBACK_TYPE                     VARCHAR2(4000),
    RESOLUTION_STATUS                 VARCHAR2(4000),
    RESOLUTION_DATE                   VARCHAR2(4000),
    ANOMALY                           VARCHAR2(4000)
);


-----------------------------
-- 1.2 SILVERTABLE 
--     Données nettoyées, typées, dédoublonnées
-----------------------------
CREATE TABLE SLV_BANKING_DATA (
    CUSTOMER_ID                       NUMBER,
    FIRST_NAME                        VARCHAR2(100),
    LAST_NAME                         VARCHAR2(100),
    AGE                               NUMBER(3),
    GENDER                            VARCHAR2(20),
    ADDRESS                           VARCHAR2(200),
    CITY                              VARCHAR2(100),
    CONTACT_NUMBER                    VARCHAR2(30),
    EMAIL                             VARCHAR2(255),
    ACCOUNT_TYPE                      VARCHAR2(50),
    ACCOUNT_BALANCE                   NUMBER(15,2),
    DATE_OF_ACCOUNT_OPENING           DATE,
    LAST_TRANSACTION_DATE             DATE,
    TRANSACTIONID                     NUMBER,
    TRANSACTION_DATE                  DATE,
    TRANSACTION_TYPE                  VARCHAR2(50),
    TRANSACTION_AMOUNT                NUMBER(15,2),
    ACCOUNT_BALANCE_AFTER_TRANSACTION NUMBER(15,2),
    BRANCH_ID                         NUMBER,
    LOAN_ID                           NUMBER,
    LOAN_AMOUNT                       NUMBER(15,2),
    LOAN_TYPE                         VARCHAR2(50),
    INTEREST_RATE                     NUMBER(5,2),
    LOAN_TERM                         NUMBER,
    APPROVAL_REJECTION_DATE           DATE,
    LOAN_STATUS                       VARCHAR2(50),
    CARDID                            NUMBER,
    CARD_TYPE                         VARCHAR2(50),
    CREDIT_LIMIT                      NUMBER(15,2),
    CREDIT_CARD_BALANCE               NUMBER(15,2),
    MINIMUM_PAYMENT_DUE               NUMBER(15,2),
    PAYMENT_DUE_DATE                  DATE,
    LAST_CREDIT_CARD_PAYMENT_DATE     DATE,
    REWARDS_POINTS                    NUMBER,
    FEEDBACK_ID                       NUMBER,
    FEEDBACK_DATE                     DATE,
    FEEDBACK_TYPE                     VARCHAR2(50),
    RESOLUTION_STATUS                 VARCHAR2(50),
    RESOLUTION_DATE                   DATE,
    ANOMALY                           NUMBER(3),
    CONSTRAINT PK_SLV_BANKING PRIMARY KEY (CUSTOMER_ID, TRANSACTIONID)
);

-----------------------------
-- 1.3 TABLES GOLD – STAR SCHEMA
-----------------------------

-- 1.3.1 DIM_DATE : Généré de 2010 à 2030
CREATE TABLE DIM_DATE (
    DATE_KEY       NUMBER(8) PRIMARY KEY,   -- yyyymmdd
    FULL_DATE      DATE,
    YEAR_NUM       NUMBER(4),
    QUARTER_NUM    NUMBER(1),
    MONTH_NUM      NUMBER(2),
    MONTH_NAME     VARCHAR2(20),
    DAY_OF_MONTH   NUMBER(2),
    DAY_OF_WEEK    NUMBER(1),
    DAY_NAME       VARCHAR2(20),
    WEEK_OF_YEAR   NUMBER(2)
);

-- 1.3.2 DIM_CUSTOMER
CREATE TABLE DIM_CUSTOMER (
    CUSTOMER_KEY                NUMBER PRIMARY KEY,
    CUSTOMER_ID                 NUMBER,
    FIRST_NAME                  VARCHAR2(100),
    LAST_NAME                   VARCHAR2(100),
    FULL_NAME                   VARCHAR2(200),
    AGE                         NUMBER(3),
    GENDER                      VARCHAR2(20),
    ADDRESS                     VARCHAR2(200),
    CITY                        VARCHAR2(100),
    ACCOUNT_TYPE                VARCHAR2(50),
    DATE_OF_ACCOUNT_OPENING     DATE,
    LOAN_TYPE                   VARCHAR2(50),
    LOAN_STATUS                 VARCHAR2(50),
    CARD_TYPE                   VARCHAR2(50),
    BRANCH_ID                   NUMBER,
    REWARDS_POINTS              NUMBER,
    CONSTRAINT UK_DIM_CUSTOMER UNIQUE (CUSTOMER_ID)
);

-- 1.3.3 DIM_PRODUCT
CREATE TABLE DIM_PRODUCT (
    PRODUCT_KEY     NUMBER PRIMARY KEY,
    PRODUCT_TYPE    VARCHAR2(50),      -- ACCOUNT / LOAN / CARD / MIXED
    ACCOUNT_TYPE    VARCHAR2(50),
    LOAN_TYPE       VARCHAR2(50),
    CARD_TYPE       VARCHAR2(50),
    DESCRIPTION     VARCHAR2(200),
    CONSTRAINT UK_DIM_PRODUCT UNIQUE (ACCOUNT_TYPE, LOAN_TYPE, CARD_TYPE)
);

-- 1.3.4 FACT_TRANSACTIONS
CREATE TABLE FACT_TRANSACTIONS (
    TRANSACTION_KEY              NUMBER PRIMARY KEY,
    CUSTOMER_KEY                 NUMBER NOT NULL,
    DATE_KEY                     NUMBER(8) NOT NULL,
    PRODUCT_KEY                  NUMBER NOT NULL,
    TRANSACTIONID                NUMBER,
    TRANSACTION_AMOUNT           NUMBER(15,2),
    ACCOUNT_BAL_BEFORE           NUMBER(15,2),
    ACCOUNT_BAL_AFTER            NUMBER(15,2),
    LOAN_AMOUNT                  NUMBER(15,2),
    INTEREST_RATE                NUMBER(5,2),
    CREDIT_LIMIT                 NUMBER(15,2),
    CREDIT_CARD_BALANCE          NUMBER(15,2),
    MINIMUM_PAYMENT_DUE          NUMBER(15,2),
    ANOMALY_FLAG                 NUMBER(3),

    -- KPIs financiers
    GLOBAL_RISK_SCORE            NUMBER(5,2),
    FINANCIAL_RUNWAY_MONTHS      NUMBER(10,2),
    CUSTOMER_PROFITABILITY       NUMBER(15,2),
    TRANSACTION_DANGER_SCORE     NUMBER(5,2),

    CONSTRAINT FK_FACT_DATE      FOREIGN KEY (DATE_KEY)     REFERENCES DIM_DATE (DATE_KEY),
    CONSTRAINT FK_FACT_CUSTOMER  FOREIGN KEY (CUSTOMER_KEY) REFERENCES DIM_CUSTOMER (CUSTOMER_KEY),
    CONSTRAINT FK_FACT_PRODUCT   FOREIGN KEY (PRODUCT_KEY)  REFERENCES DIM_PRODUCT (PRODUCT_KEY)
);

-- 1.3.5 TABLE DES ALERTES FRAUDE
CREATE TABLE ALERTS_LOG (
    ALERT_ID          NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY,
    ALERT_TIMESTAMP   DATE DEFAULT SYSDATE,
    CUSTOMER_KEY      NUMBER,
    TRANSACTION_KEY   NUMBER,
    RISK_SCORE        NUMBER(5,2),
    DANGER_SCORE      NUMBER(5,2),
    ALERT_MESSAGE     VARCHAR2(400),
    STATUS            VARCHAR2(50) DEFAULT 'OPEN'
);

-----------------------------
-- 1.4 SEQUENCES POUR LES DIMENSIONS & FACT
-----------------------------
CREATE SEQUENCE SEQ_DIM_CUSTOMER START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE SEQ_DIM_PRODUCT  START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE SEQ_FACT_TRANSACTIONS START WITH 1 INCREMENT BY 1 NOCACHE;

------------------------------------------------------------------------
-- 2. PACKAGE TECHNIQUE : PKG_DATA_CLEANING
------------------------------------------------------------------------
--   - FN_STD_PHONE : standardisation téléphone
--   - FN_FIX_EMAIL : correction/normalisation email
--   - SP_CLEAN_STAGING : Bronze -> Silver (typage, nettoyages, dédoublonnage)
------------------------------------------------------------------------

CREATE OR REPLACE PACKAGE PKG_DATA_CLEANING AS
    FUNCTION FN_STD_PHONE (p_phone IN VARCHAR2) RETURN VARCHAR2;
    FUNCTION FN_FIX_EMAIL (p_email IN VARCHAR2) RETURN VARCHAR2;

    PROCEDURE SP_CLEAN_STAGING;
END PKG_DATA_CLEANING;
/

CREATE OR REPLACE PACKAGE BODY PKG_DATA_CLEANING AS

    --------------------------------------------------------------------
    -- FN_STD_PHONE
    --  - Garde uniquement les chiffres
    --  - Si > 10 chiffres : garde les 10 derniers
    --  - Préfixe par '+1 ' pour standardisation simple
    --------------------------------------------------------------------
    FUNCTION FN_STD_PHONE (p_phone IN VARCHAR2) RETURN VARCHAR2 IS
        v_digits VARCHAR2(50);
    BEGIN
        IF p_phone IS NULL THEN
            RETURN NULL;
        END IF;

        v_digits := REGEXP_REPLACE(p_phone, '[^0-9]', '');

        IF LENGTH(v_digits) > 10 THEN
            v_digits := SUBSTR(v_digits, -10);
        END IF;

        IF v_digits IS NULL THEN
            RETURN NULL;
        END IF;

        RETURN '+1 ' || v_digits;
    END FN_STD_PHONE;

    --------------------------------------------------------------------
    -- FN_FIX_EMAIL
    --  - Trim + lower
    --  - Si format invalide :
    --       * si contient au moins un '@' -> NULL (à revoir manuellement)
    --       * sinon ajoute '@unknown.com'
    --------------------------------------------------------------------
    FUNCTION FN_FIX_EMAIL (p_email IN VARCHAR2) RETURN VARCHAR2 IS
        v_email VARCHAR2(320);
    BEGIN
        IF p_email IS NULL THEN
            RETURN NULL;
        END IF;

        v_email := LOWER(TRIM(p_email));

        IF REGEXP_LIKE(v_email,
                       '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') THEN
            RETURN v_email;
        END IF;

        IF INSTR(v_email, '@') > 0 THEN
            -- Email douteux : on renvoie NULL pour audit manuel
            RETURN NULL;
        ELSE
            -- Pas de '@' -> on force un domaine générique
            RETURN v_email || '@unknown.com';
        END IF;
    END FN_FIX_EMAIL;

    --------------------------------------------------------------------
    -- SP_CLEAN_STAGING
    --  - Vide la Silver
    --  - Insère depuis Bronze avec :
    --      * Trim / Upper sur noms & villes
    --      * Standardisation téléphone & email
    --      * Typage (TO_NUMBER / TO_DATE)
    --      * Détection doublons via ROW_NUMBER()
    --------------------------------------------------------------------
    PROCEDURE SP_CLEAN_STAGING IS
    BEGIN
        -- On recrée un snapshot complet à chaque run
        DELETE FROM SLV_BANKING_DATA;

        INSERT INTO SLV_BANKING_DATA (
            CUSTOMER_ID,
            FIRST_NAME,
            LAST_NAME,
            AGE,
            GENDER,
            ADDRESS,
            CITY,
            CONTACT_NUMBER,
            EMAIL,
            ACCOUNT_TYPE,
            ACCOUNT_BALANCE,
            DATE_OF_ACCOUNT_OPENING,
            LAST_TRANSACTION_DATE,
            TRANSACTIONID,
            TRANSACTION_DATE,
            TRANSACTION_TYPE,
            TRANSACTION_AMOUNT,
            ACCOUNT_BALANCE_AFTER_TRANSACTION,
            BRANCH_ID,
            LOAN_ID,
            LOAN_AMOUNT,
            LOAN_TYPE,
            INTEREST_RATE,
            LOAN_TERM,
            APPROVAL_REJECTION_DATE,
            LOAN_STATUS,
            CARDID,
            CARD_TYPE,
            CREDIT_LIMIT,
            CREDIT_CARD_BALANCE,
            MINIMUM_PAYMENT_DUE,
            PAYMENT_DUE_DATE,
            LAST_CREDIT_CARD_PAYMENT_DATE,
            REWARDS_POINTS,
            FEEDBACK_ID,
            FEEDBACK_DATE,
            FEEDBACK_TYPE,
            RESOLUTION_STATUS,
            RESOLUTION_DATE,
            ANOMALY
        )
        SELECT
            TO_NUMBER(TRIM(CUSTOMER_ID)),
            UPPER(TRIM(FIRST_NAME)),
            UPPER(TRIM(LAST_NAME)),
            TO_NUMBER(TRIM(AGE)),
            UPPER(TRIM(GENDER)),
            TRIM(ADDRESS),
            UPPER(TRIM(CITY)),
            FN_STD_PHONE(CONTACT_NUMBER),
            FN_FIX_EMAIL(EMAIL),
            UPPER(TRIM(ACCOUNT_TYPE)),
            TO_NUMBER(ACCOUNT_BALANCE),
            TO_DATE(DATE_OF_ACCOUNT_OPENING, 'MM/DD/YYYY'),
            TO_DATE(LAST_TRANSACTION_DATE, 'MM/DD/YYYY'),
            TO_NUMBER(TRANSACTIONID),
            TO_DATE(TRANSACTION_DATE, 'MM/DD/YYYY'),
            UPPER(TRIM(TRANSACTION_TYPE)),
            TO_NUMBER(TRANSACTION_AMOUNT),
            TO_NUMBER(ACCOUNT_BALANCE_AFTER_TRANSACTION),
            TO_NUMBER(BRANCH_ID),
            TO_NUMBER(LOAN_ID),
            TO_NUMBER(LOAN_AMOUNT),
            UPPER(TRIM(LOAN_TYPE)),
            TO_NUMBER(INTEREST_RATE),
            TO_NUMBER(LOAN_TERM),
            TO_DATE(APPROVAL_REJECTION_DATE, 'MM/DD/YYYY'),
            UPPER(TRIM(LOAN_STATUS)),
            TO_NUMBER(CARDID),
            UPPER(TRIM(CARD_TYPE)),
            TO_NUMBER(CREDIT_LIMIT),
            TO_NUMBER(CREDIT_CARD_BALANCE),
            TO_NUMBER(MINIMUM_PAYMENT_DUE),
            TO_DATE(PAYMENT_DUE_DATE, 'MM/DD/YYYY'),
            TO_DATE(LAST_CREDIT_CARD_PAYMENT_DATE, 'MM/DD/YYYY'),
            TO_NUMBER(REWARDS_POINTS),
            TO_NUMBER(FEEDBACK_ID),
            TO_DATE(FEEDBACK_DATE, 'MM/DD/YYYY'),
            UPPER(TRIM(FEEDBACK_TYPE)),
            UPPER(TRIM(RESOLUTION_STATUS)),
            TO_DATE(RESOLUTION_DATE, 'MM/DD/YYYY'),
            TO_NUMBER(ANOMALY)
        FROM (
            SELECT
                b.*,
                ROW_NUMBER() OVER (
                    PARTITION BY b.CUSTOMER_ID, b.TRANSACTIONID
                    ORDER BY TO_DATE(b.TRANSACTION_DATE, 'MM/DD/YYYY') DESC
                ) AS rn
            FROM BRZ_BANKING_IMPORT b
        )
        WHERE rn = 1;  -- on garde la version la plus récente pour chaque client/transaction

        COMMIT;
    END SP_CLEAN_STAGING;

END PKG_DATA_CLEANING;
/

------------------------------------------------------------------------
-- 3. PACKAGE METIER : PKG_BUSINESS_LOGIC
------------------------------------------------------------------------
--   - KPIs :
--        * Global Risk Score [0-100]
--        * Financial Runway (mois)
--        * Customer Profitability
--        * Transaction Danger Score [0-100]
--   - SP_GEN_CALENDAR : remplit DIM_DATE via WHILE LOOP
--   - SP_POPULATE_GOLD : ETL ligne par ligne via CURSOR + FOR LOOP
------------------------------------------------------------------------

CREATE OR REPLACE PACKAGE PKG_BUSINESS_LOGIC AS

    FUNCTION FN_GLOBAL_RISK_SCORE (
        p_loan_amount          IN NUMBER,
        p_cc_balance           IN NUMBER,
        p_assets_total         IN NUMBER
    ) RETURN NUMBER;

    FUNCTION FN_FINANCIAL_RUNWAY (
        p_current_balance      IN NUMBER,
        p_monthly_charges      IN NUMBER
    ) RETURN NUMBER;

    FUNCTION FN_CUSTOMER_PROFITABILITY (
        p_loan_amount          IN NUMBER,
        p_interest_rate        IN NUMBER,
        p_cc_balance           IN NUMBER
    ) RETURN NUMBER;

    FUNCTION FN_TRANSACTION_DANGER_SCORE (
        p_tx_amount            IN NUMBER,
        p_balance_after        IN NUMBER,
        p_anomaly_flag         IN NUMBER
    ) RETURN NUMBER;

    -- Génération de DIM_DATE (2010-01-01 -> 2030-12-31)
    PROCEDURE SP_GEN_CALENDAR;

    -- ETL Silver -> Gold avec CURSOR / FOR LOOP
    PROCEDURE SP_POPULATE_GOLD;

END PKG_BUSINESS_LOGIC;
/

CREATE OR REPLACE PACKAGE BODY PKG_BUSINESS_LOGIC AS

    --------------------------------------------------------------------
    -- FN_GLOBAL_RISK_SCORE
    --  Risk Score = (Dettes Prêts + Dettes Cartes) / Avoirs Totaux * 100
    --  Clampé entre 0 et 100
    --------------------------------------------------------------------
    FUNCTION FN_GLOBAL_RISK_SCORE (
        p_loan_amount          IN NUMBER,
        p_cc_balance           IN NUMBER,
        p_assets_total         IN NUMBER
    ) RETURN NUMBER IS
        v_debts     NUMBER := NVL(p_loan_amount, 0) + NVL(p_cc_balance, 0);
        v_assets    NUMBER := GREATEST(NVL(p_assets_total, 0), 1);
        v_score     NUMBER;
    BEGIN
        v_score := (v_debts / v_assets) * 100;
        IF v_score < 0 THEN
            v_score := 0;
        ELSIF v_score > 100 THEN
            v_score := 100;
        END IF;
        RETURN ROUND(v_score, 2);
    END FN_GLOBAL_RISK_SCORE;

    --------------------------------------------------------------------
    -- FN_FINANCIAL_RUNWAY
    --  Mois de survie = Solde / Charges Mensuelles
    --  (On renvoie 0 si charges nulles ou très faibles)
    --------------------------------------------------------------------
    FUNCTION FN_FINANCIAL_RUNWAY (
        p_current_balance      IN NUMBER,
        p_monthly_charges      IN NUMBER
    ) RETURN NUMBER IS
        v_balance NUMBER := NVL(p_current_balance, 0);
        v_charges NUMBER := NVL(p_monthly_charges, 0);
    BEGIN
        IF v_charges < 1 THEN
            RETURN 0;
        END IF;
        RETURN ROUND(v_balance / v_charges, 2);
    END FN_FINANCIAL_RUNWAY;

    --------------------------------------------------------------------
    -- FN_CUSTOMER_PROFITABILITY
    --  Valeur client = Intérêts annuels sur prêt + intérêts carte
    --  Hypothèse : Taux carte ~ 18% annuel sur le solde
    --------------------------------------------------------------------
    FUNCTION FN_CUSTOMER_PROFITABILITY (
        p_loan_amount          IN NUMBER,
        p_interest_rate        IN NUMBER,
        p_cc_balance           IN NUMBER
    ) RETURN NUMBER IS
        v_loan_amount   NUMBER := NVL(p_loan_amount, 0);
        v_rate          NUMBER := NVL(p_interest_rate, 0) / 100;
        v_cc_balance    NUMBER := NVL(p_cc_balance, 0);
        v_profit        NUMBER;
    BEGIN
        v_profit :=
              v_loan_amount * v_rate               -- intérêts sur prêt
            + v_cc_balance * (18 / 100);           -- intérêt carte
        RETURN ROUND(v_profit, 2);
    END FN_CUSTOMER_PROFITABILITY;

    --------------------------------------------------------------------
    -- FN_TRANSACTION_DANGER_SCORE
    --  Danger Score basé sur :
    --     - ratio montant / (|solde après| + 1)
    --     - pénalisation forte si anomalie = -1 (fraude potentielle)
    --------------------------------------------------------------------
    FUNCTION FN_TRANSACTION_DANGER_SCORE (
        p_tx_amount            IN NUMBER,
        p_balance_after        IN NUMBER,
        p_anomaly_flag         IN NUMBER
    ) RETURN NUMBER IS
        v_tx_amount    NUMBER := ABS(NVL(p_tx_amount, 0));
        v_bal          NUMBER := ABS(NVL(p_balance_after, 0)) + 1;
        v_base_score   NUMBER;
        v_score        NUMBER;
    BEGIN
        v_base_score := (v_tx_amount / v_bal) * 50;  -- jusqu'à 50 points

        IF NVL(p_anomaly_flag, 0) = -1 THEN
            v_score := v_base_score + 50;           -- boost de 50 points
        ELSE
            v_score := v_base_score;
        END IF;

        IF v_score < 0 THEN
            v_score := 0;
        ELSIF v_score > 100 THEN
            v_score := 100;
        END IF;

        RETURN ROUND(v_score, 2);
    END FN_TRANSACTION_DANGER_SCORE;

    --------------------------------------------------------------------
    -- SP_GEN_CALENDAR
    --  Remplit DIM_DATE via WHILE LOOP pour la période 2010-01-01 à 2030-12-31
    --------------------------------------------------------------------
    PROCEDURE SP_GEN_CALENDAR IS
        v_date       DATE := DATE '2010-01-01';
        v_end_date   DATE := DATE '2030-12-31';
        v_date_key   NUMBER;
        v_year       NUMBER;
        v_quarter    NUMBER;
        v_month      NUMBER;
        v_day        NUMBER;
        v_dow        NUMBER;
        v_week       NUMBER;
    BEGIN
        DELETE FROM DIM_DATE;

        WHILE v_date <= v_end_date LOOP
            v_date_key := TO_NUMBER(TO_CHAR(v_date, 'YYYYMMDD'));
            v_year     := TO_NUMBER(TO_CHAR(v_date, 'YYYY'));
            v_quarter  := TO_NUMBER(TO_CHAR(v_date, 'Q'));
            v_month    := TO_NUMBER(TO_CHAR(v_date, 'MM'));
            v_day      := TO_NUMBER(TO_CHAR(v_date, 'DD'));
            v_dow      := TO_NUMBER(TO_CHAR(v_date, 'D'));
            v_week     := TO_NUMBER(TO_CHAR(v_date, 'WW'));

            INSERT INTO DIM_DATE (
                DATE_KEY, FULL_DATE, YEAR_NUM, QUARTER_NUM,
                MONTH_NUM, MONTH_NAME, DAY_OF_MONTH,
                DAY_OF_WEEK, DAY_NAME, WEEK_OF_YEAR
            )
            VALUES (
                v_date_key,
                v_date,
                v_year,
                v_quarter,
                v_month,
                TO_CHAR(v_date, 'Month'),
                v_day,
                v_dow,
                TO_CHAR(v_date, 'Day'),
                v_week
            );

            v_date := v_date + 1;
        END LOOP;

        COMMIT;
    END SP_GEN_CALENDAR;

    --------------------------------------------------------------------
    -- SP_POPULATE_GOLD
    --  - Parcourt SLV_BANKING_DATA ligne par ligne via CURSOR + FOR LOOP
    --  - Gère la dimension client (insert si nouveau)
    --  - Gère la dimension produit (insert si nouveau)
    --  - Calcule les KPIs via les fonctions du package
    --  - Insère dans FACT_TRANSACTIONS
    --------------------------------------------------------------------
    PROCEDURE SP_POPULATE_GOLD IS

        CURSOR c_silver IS
            SELECT *
            FROM SLV_BANKING_DATA;

        v_customer_key   DIM_CUSTOMER.CUSTOMER_KEY%TYPE;
        v_product_key    DIM_PRODUCT.PRODUCT_KEY%TYPE;
        v_date_key       DIM_DATE.DATE_KEY%TYPE;
        v_tx_key         FACT_TRANSACTIONS.TRANSACTION_KEY%TYPE;

        v_assets_total   NUMBER;
        v_monthly_charges NUMBER;
        v_risk_score     NUMBER;
        v_runway         NUMBER;
        v_profit         NUMBER;
        v_danger_score   NUMBER;

    BEGIN
        -- On repart d'un fact vide pour simplifier le POC
        DELETE FROM FACT_TRANSACTIONS;

        FOR r IN c_silver LOOP

            ----------------------------------------------------------------
            -- 1) DIM_CUSTOMER : recherche ou insertion
            ----------------------------------------------------------------
            BEGIN
                SELECT CUSTOMER_KEY
                INTO   v_customer_key
                FROM   DIM_CUSTOMER
                WHERE  CUSTOMER_ID = r.CUSTOMER_ID;

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    v_customer_key := SEQ_DIM_CUSTOMER.NEXTVAL;

                    INSERT INTO DIM_CUSTOMER (
                        CUSTOMER_KEY,
                        CUSTOMER_ID,
                        FIRST_NAME,
                        LAST_NAME,
                        FULL_NAME,
                        AGE,
                        GENDER,
                        ADDRESS,
                        CITY,
                        ACCOUNT_TYPE,
                        DATE_OF_ACCOUNT_OPENING,
                        LOAN_TYPE,
                        LOAN_STATUS,
                        CARD_TYPE,
                        BRANCH_ID,
                        REWARDS_POINTS
                    )
                    VALUES (
                        v_customer_key,
                        r.CUSTOMER_ID,
                        r.FIRST_NAME,
                        r.LAST_NAME,
                        r.FIRST_NAME || ' ' || r.LAST_NAME,
                        r.AGE,
                        r.GENDER,
                        r.ADDRESS,
                        r.CITY,
                        r.ACCOUNT_TYPE,
                        r.DATE_OF_ACCOUNT_OPENING,
                        r.LOAN_TYPE,
                        r.LOAN_STATUS,
                        r.CARD_TYPE,
                        r.BRANCH_ID,
                        r.REWARDS_POINTS
                    );
            END;

            ----------------------------------------------------------------
            -- 2) DIM_PRODUCT : recherche ou insertion
            --    Product_type simple selon présence prêt / carte
            ----------------------------------------------------------------
            DECLARE
                v_product_type VARCHAR2(50);
            BEGIN
                IF r.LOAN_AMOUNT IS NOT NULL AND r.CREDIT_LIMIT IS NOT NULL THEN
                    v_product_type := 'MIXED';
                ELSIF r.LOAN_AMOUNT IS NOT NULL THEN
                    v_product_type := 'LOAN';
                ELSIF r.CREDIT_LIMIT IS NOT NULL THEN
                    v_product_type := 'CARD';
                ELSE
                    v_product_type := 'ACCOUNT';
                END IF;

                BEGIN
                    SELECT PRODUCT_KEY
                    INTO   v_product_key
                    FROM   DIM_PRODUCT
                    WHERE  ACCOUNT_TYPE = r.ACCOUNT_TYPE
                    AND    NVL(LOAN_TYPE, 'X') = NVL(r.LOAN_TYPE, 'X')
                    AND    NVL(CARD_TYPE, 'X') = NVL(r.CARD_TYPE, 'X');
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        v_product_key := SEQ_DIM_PRODUCT.NEXTVAL;

                        INSERT INTO DIM_PRODUCT (
                            PRODUCT_KEY,
                            PRODUCT_TYPE,
                            ACCOUNT_TYPE,
                            LOAN_TYPE,
                            CARD_TYPE,
                            DESCRIPTION
                        )
                        VALUES (
                            v_product_key,
                            v_product_type,
                            r.ACCOUNT_TYPE,
                            r.LOAN_TYPE,
                            r.CARD_TYPE,
                            v_product_type || ' - ' ||
                            NVL(r.ACCOUNT_TYPE, 'N/A') || ' / ' ||
                            NVL(r.LOAN_TYPE, 'N/A')   || ' / ' ||
                            NVL(r.CARD_TYPE, 'N/A')
                        );
                END;
            END;

            ----------------------------------------------------------------
            -- 3) DATE_KEY à partir de TRANSACTION_DATE
            ----------------------------------------------------------------
            v_date_key := TO_NUMBER(TO_CHAR(r.TRANSACTION_DATE, 'YYYYMMDD'));

            ----------------------------------------------------------------
            -- 4) Calcul des KPIs
            ----------------------------------------------------------------
            -- On approxime les avoirs totaux par :
            --    solde après transaction + 5% de la ligne de crédit
            v_assets_total := NVL(r.ACCOUNT_BALANCE_AFTER_TRANSACTION, 0)
                              + NVL(r.CREDIT_LIMIT, 0) * 0.05;

            -- Charges mensuelles estimées :
            --    MIN_PAYMENT_DUE + 3% du solde carte + 1% du prêt
            v_monthly_charges :=
                  NVL(r.MINIMUM_PAYMENT_DUE, 0)
                + NVL(r.CREDIT_CARD_BALANCE, 0) * 0.03
                + NVL(r.LOAN_AMOUNT, 0) * 0.01;

            v_risk_score := FN_GLOBAL_RISK_SCORE(
                                p_loan_amount  => r.LOAN_AMOUNT,
                                p_cc_balance   => r.CREDIT_CARD_BALANCE,
                                p_assets_total => v_assets_total
                            );

            v_runway := FN_FINANCIAL_RUNWAY(
                            p_current_balance => r.ACCOUNT_BALANCE_AFTER_TRANSACTION,
                            p_monthly_charges => v_monthly_charges
                        );

            v_profit := FN_CUSTOMER_PROFITABILITY(
                            p_loan_amount   => r.LOAN_AMOUNT,
                            p_interest_rate => r.INTEREST_RATE,
                            p_cc_balance    => r.CREDIT_CARD_BALANCE
                        );

            v_danger_score := FN_TRANSACTION_DANGER_SCORE(
                                  p_tx_amount     => r.TRANSACTION_AMOUNT,
                                  p_balance_after => r.ACCOUNT_BALANCE_AFTER_TRANSACTION,
                                  p_anomaly_flag  => r.ANOMALY
                              );

            ----------------------------------------------------------------
            -- 5) Insertion FACT_TRANSACTIONS
            ----------------------------------------------------------------
            v_tx_key := SEQ_FACT_TRANSACTIONS.NEXTVAL;

            INSERT INTO FACT_TRANSACTIONS (
                TRANSACTION_KEY,
                CUSTOMER_KEY,
                DATE_KEY,
                PRODUCT_KEY,
                TRANSACTIONID,
                TRANSACTION_AMOUNT,
                ACCOUNT_BAL_BEFORE,
                ACCOUNT_BAL_AFTER,
                LOAN_AMOUNT,
                INTEREST_RATE,
                CREDIT_LIMIT,
                CREDIT_CARD_BALANCE,
                MINIMUM_PAYMENT_DUE,
                ANOMALY_FLAG,
                GLOBAL_RISK_SCORE,
                FINANCIAL_RUNWAY_MONTHS,
                CUSTOMER_PROFITABILITY,
                TRANSACTION_DANGER_SCORE
            )
            VALUES (
                v_tx_key,
                v_customer_key,
                v_date_key,
                v_product_key,
                r.TRANSACTIONID,
                r.TRANSACTION_AMOUNT,
                -- solde avant = après + ou - montant selon type
                CASE
                    WHEN UPPER(r.TRANSACTION_TYPE) = 'DEPOSIT'
                        THEN NVL(r.ACCOUNT_BALANCE_AFTER_TRANSACTION, 0) - NVL(r.TRANSACTION_AMOUNT, 0)
                    WHEN UPPER(r.TRANSACTION_TYPE) IN ('WITHDRAWAL', 'TRANSFER')
                        THEN NVL(r.ACCOUNT_BALANCE_AFTER_TRANSACTION, 0) + NVL(r.TRANSACTION_AMOUNT, 0)
                    ELSE NULL
                END,
                r.ACCOUNT_BALANCE_AFTER_TRANSACTION,
                r.LOAN_AMOUNT,
                r.INTEREST_RATE,
                r.CREDIT_LIMIT,
                r.CREDIT_CARD_BALANCE,
                r.MINIMUM_PAYMENT_DUE,
                r.ANOMALY,
                v_risk_score,
                v_runway,
                v_profit,
                v_danger_score
            );

        END LOOP;

        COMMIT;
    END SP_POPULATE_GOLD;

END PKG_BUSINESS_LOGIC;
/

------------------------------------------------------------------------
-- 4. TRIGGER ANTI-FRAUDE : TRG_DETECT_CRITICAL_RISK
------------------------------------------------------------------------
--  AFTER INSERT sur FACT_TRANSACTIONS
--  Si Transaction_Danger_Score > 80 ET Global_Risk_Score > 70
--     -> insertion dans ALERTS_LOG
------------------------------------------------------------------------

CREATE OR REPLACE TRIGGER TRG_DETECT_CRITICAL_RISK
AFTER INSERT ON FACT_TRANSACTIONS
FOR EACH ROW
DECLARE
    v_msg VARCHAR2(400);
BEGIN
    IF :NEW.TRANSACTION_DANGER_SCORE > 80
       AND :NEW.GLOBAL_RISK_SCORE > 70 THEN

        v_msg := 'Alerte Rouge : Retrait/transaction suspecte pour le client_key='
                 || :NEW.CUSTOMER_KEY
                 || ', transaction_key=' || :NEW.TRANSACTION_KEY;

        INSERT INTO ALERTS_LOG (
            ALERT_TIMESTAMP,
            CUSTOMER_KEY,
            TRANSACTION_KEY,
            RISK_SCORE,
            DANGER_SCORE,
            ALERT_MESSAGE,
            STATUS
        )
        VALUES (
            SYSDATE,
            :NEW.CUSTOMER_KEY,
            :NEW.TRANSACTION_KEY,
            :NEW.GLOBAL_RISK_SCORE,
            :NEW.TRANSACTION_DANGER_SCORE,
            v_msg,
            'OPEN'
        );
    END IF;
END TRG_DETECT_CRITICAL_RISK;
/

------------------------------------------------------------------------
-- 5. EXEMPLES D’INSERTION & APPELS DES PROCEDURES (POC)
------------------------------------------------------------------------

-----------------------------
-- 5.1 Exemple : insertion d’une ligne dans BRZ_BANKING_IMPORT
--     (normalement : INSERT SELECT depuis l’external table)
-----------------------------
INSERT INTO BRZ_BANKING_IMPORT (
    CUSTOMER_ID,FIRST_NAME,LAST_NAME,AGE,GENDER,ADDRESS,CITY,
    CONTACT_NUMBER,EMAIL,ACCOUNT_TYPE,ACCOUNT_BALANCE,
    DATE_OF_ACCOUNT_OPENING,LAST_TRANSACTION_DATE,
    TRANSACTIONID,TRANSACTION_DATE,TRANSACTION_TYPE,
    TRANSACTION_AMOUNT,ACCOUNT_BALANCE_AFTER_TRANSACTION,
    BRANCH_ID,LOAN_ID,LOAN_AMOUNT,LOAN_TYPE,INTEREST_RATE,
    LOAN_TERM,APPROVAL_REJECTION_DATE,LOAN_STATUS,
    CARDID,CARD_TYPE,CREDIT_LIMIT,CREDIT_CARD_BALANCE,
    MINIMUM_PAYMENT_DUE,PAYMENT_DUE_DATE,
    LAST_CREDIT_CARD_PAYMENT_DATE,REWARDS_POINTS,
    FEEDBACK_ID,FEEDBACK_DATE,FEEDBACK_TYPE,
    RESOLUTION_STATUS,RESOLUTION_DATE,ANOMALY
)
VALUES (
    '1','Joshua','Hall','45','Male','Address_1','Fort Worth',
    '19458794854','joshua.hall@kag.com','Current','1313.38',
    '5/26/2006','4/23/2023',
    '1','12/7/2023','Withdrawal',
    '1457.61','2770.99',
    '43','1','32200.06','Mortgage','2.64',
    '36','5/11/2021','Rejected',
    '1','AMEX','1737.88','4524.32',
    '226.22','11/26/2023',
    '3/20/2023','8142',
    '1','10/6/2023','Suggestion',
    'Resolved','1/22/2023','1'
);

COMMIT;

-----------------------------
-- 5.2 Lancement de la chaîne ETL
-----------------------------

-- 1) Nettoyage Bronze -> Silver
BEGIN
    PKG_DATA_CLEANING.SP_CLEAN_STAGING;
END;
/

-- 2) Génération de la dimension temps (2010-2030)
BEGIN
    PKG_BUSINESS_LOGIC.SP_GEN_CALENDAR;
END;
/

-- 3) Population du schéma en étoile (Gold)
BEGIN
    PKG_BUSINESS_LOGIC.SP_POPULATE_GOLD;
END;
/

-----------------------------
-- 5.3 Quelques requêtes de contrôle (pour Power BI / analyse)
-----------------------------

-- Risk Monitor : scatter plot Risk Score vs Profitability
--   (Power BI se connectera directement à FACT_TRANSACTIONS + DIM_CUSTOMER)
SELECT
    f.GLOBAL_RISK_SCORE,
    f.CUSTOMER_PROFITABILITY,
    c.CITY,
    c.AGE,
    c.GENDER
FROM FACT_TRANSACTIONS f
JOIN DIM_CUSTOMER c ON f.CUSTOMER_KEY = c.CUSTOMER_KEY;

-- Fraud Detection : alertes Danger Score élevées
SELECT
    a.ALERT_ID,
    a.ALERT_TIMESTAMP,
    a.CUSTOMER_KEY,
    a.TRANSACTION_KEY,
    a.RISK_SCORE,
    a.DANGER_SCORE,
    a.ALERT_MESSAGE,
    a.STATUS
FROM ALERTS_LOG a
ORDER BY a.ALERT_TIMESTAMP DESC;

-- Financial Health : runway moyen par ville / tranche d’âge
SELECT
    c.CITY,
    TRUNC(c.AGE / 10) * 10 AS AGE_BAND,
    AVG(f.FINANCIAL_RUNWAY_MONTHS) AS AVG_RUNWAY_MONTHS
FROM FACT_TRANSACTIONS f
JOIN DIM_CUSTOMER c ON f.CUSTOMER_KEY = c.CUSTOMER_KEY
GROUP BY c.CITY, TRUNC(c.AGE / 10) * 10
ORDER BY c.CITY, AGE_BAND;