CREATE OR ALTER PROCEDURE PWC_SP_Validate_InventOperationalSiteV2Entity
AS
BEGIN

-- Mandatory fields missing
    -- SiteId is blank
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_InventOperationalSiteV2Entity' TABLEID, 
        'SiteId' ERRORCOLUMN, 
        PWCROWID ROWID, 
        1 CATEGORY, 
        'SiteId is blank' ERRORDESC, 
        '' ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_InventOperationalSiteV2Entity A
    WHERE 
        SiteId = '' OR SiteId IS NULL;

-- Business reqd fields missing
    -- SiteName is blank
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_InventOperationalSiteV2Entity' TABLEID, 
        'SiteName' ERRORCOLUMN, 
        PWCROWID ROWID, 
        8 CATEGORY, 
        'SiteName is blank' ERRORDESC, 
        '' ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_InventOperationalSiteV2Entity A
    WHERE 
        SiteName = '' OR SiteName IS NULL;


-- Duplicate occurence
    -- SiteId and DATAAREAID has duplicate values
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_InventOperationalSiteV2Entity' TABLEID, 
        'SiteId' ERRORCOLUMN, 
        PWCROWID ROWID, 
        3 CATEGORY, 
        CASE 
            WHEN LEN(SiteId) > 10 THEN 
                'SiteId has duplicate values upon truncation in ' + DATAAREAID
            ELSE 
                'SiteId has duplicate values in ' + DATAAREAID
        END ERRORDESC, 
        SiteId ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_InventOperationalSiteV2Entity A
    WHERE 
        CONCAT(LEFT(SiteId, 10), DATAAREAID) IN (
        SELECT CONCAT(LEFT(SiteId, 10), DATAAREAID) 
        FROM PWC_T_InventOperationalSiteV2Entity
        GROUP BY LEFT(SiteId, 10), DATAAREAID 
        HAVING COUNT(*) > 1
        );



-- Invalid submaster reference
	-- PRIMARYADDRESSCOUNTRYREGIONID, PRIMARYADDRESSCITY, PRIMARYADDRESSSTATEID validation
	INSERT INTO PWCERRORTABLE
	SELECT * FROM (
		SELECT 
			'PWC_T_InventOperationalSiteV2Entity' TABLEID, 
			CASE 
				WHEN COUNT(B.COUNTRYREGIONID) = 0 THEN '(PRIMARYADDRESSCOUNTRYREGIONID, PRIMARYADDRESSCITY, PRIMARYADDRESSSTATEID)'
				WHEN COUNT(E.CATEGORY) <> 0 THEN '(PRIMARYADDRESSCOUNTRYREGIONID, PRIMARYADDRESSCITY, PRIMARYADDRESSSTATEID),[PWC_T_LogisticsAddressCityEntity]'
			END ERRORCOLUMN, 
			A.PWCROWID ROWID, 
			CASE 
				WHEN COUNT(B.COUNTRYREGIONID) = 0 THEN 4
				WHEN COUNT(E.CATEGORY) <> 0 THEN 5
			END CATEGORY, 
			CASE 
				WHEN COUNT(B.COUNTRYREGIONID) = 0 THEN 'PRIMARYADDRESSCOUNTRYREGIONID, PRIMARYADDRESSCITY, PRIMARYADDRESSSTATEID is not present in COUNTRYREGIONID, NAME, STATEID of PWC_T_LogisticsAddressCityEntity'
				WHEN COUNT(E.CATEGORY) <> 0 THEN 'PWC_T_LogisticsAddressCityEntity has error(s) in corresponding COUNTRYREGIONID, NAME, STATEID'
			END ERRORDESC,
			CONCAT('(',A.PRIMARYADDRESSCOUNTRYREGIONID, ', ', A.PRIMARYADDRESSCITY, ', ', A.PRIMARYADDRESSSTATEID,')') ERRORVALUE,
			A.DATAAREAID DATAAREAID
		FROM PWC_T_InventOperationalSiteV2Entity A
		LEFT JOIN PWC_T_LogisticsAddressCityEntity B
			ON (B.DATAAREAID = A.DATAAREAID OR UPPER(B.DATAAREAID) = 'GLOBAL') 
			AND CONCAT(A.PRIMARYADDRESSCOUNTRYREGIONID, A.PRIMARYADDRESSCITY, A.PRIMARYADDRESSSTATEID) = CONCAT(B.COUNTRYREGIONID, B.NAME, B.STATEID)
		LEFT JOIN PWCERRORTABLE E
			ON E.TABLEID = 'PWC_T_LogisticsAddressCityEntity' AND E.CATEGORY IN (SELECT ID FROM PWCCATEGORY WHERE STATUS = 3)
				AND B.PWCROWID = E.ROWID
		WHERE 
			A.PRIMARYADDRESSCOUNTRYREGIONID IS NOT NULL AND A.PRIMARYADDRESSCITY IS NOT NULL AND A.PRIMARYADDRESSSTATEID IS NOT NULL
		GROUP BY A.PWCROWID, A.PRIMARYADDRESSCOUNTRYREGIONID, A.PRIMARYADDRESSCITY, A.PRIMARYADDRESSSTATEID, A.DATAAREAID
	) a
	WHERE CATEGORY IS NOT NULL;



-- String length exceeded
    -- SiteId exceeds max length 10
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_InventOperationalSiteV2Entity' TABLEID, 
        'SiteId' ERRORCOLUMN, 
        PWCROWID ROWID, 
        7 CATEGORY, 
        'SiteId exceeds max length 10' ERRORDESC, 
        SiteId ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_InventOperationalSiteV2Entity A
    WHERE LEN(SiteId) > 10;

    -- SiteName exceeds max length 60
    INSERT INTO PWCERRORTABLE
    SELECT 
        'PWC_T_InventOperationalSiteV2Entity' TABLEID, 
        'SiteName' ERRORCOLUMN, 
        PWCROWID ROWID, 
        7 CATEGORY, 
        'SiteName exceeds max length 60' ERRORDESC, 
        SiteName ERRORVALUE,
        A.DATAAREAID DATAAREAID
    FROM PWC_T_InventOperationalSiteV2Entity A
    WHERE LEN(SiteName) > 60;

    EXEC PWC_SP_CALCULATESUCCESSFULCOUNT @TableName = 'PWC_T_InventOperationalSiteV2Entity'
END;

