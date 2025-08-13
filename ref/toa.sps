Alt regnes for alle overalt - dvs de som ikke drikker settes til 0.
----------------------------

FREKVENSER siste år basert på disse::
Drukket2=1 Daglig
Drukk2a=1  4-5 uk
Drukk2a=2  2-3uk
Drukk2a=3  ca 1 dag uk
Drukk2b=1  Flere enn 3 dg i mnd
Drukk2b=2  2-3 dg mnd
Drukk2b=3  ca 1 dag mnd
Drukk2c=1  flere enn 3 dager i året
Drukk2c=2  2-3 dager året
Drukk2c=3  omtrent 1 dag året



iF (Drukket1=2)NYDRUKKET_12=0.
iF (Drukket2=1)NYDRUKKET_12=1.
iF (Drukk2a=1)NYDRUKKET_12=2.
iF (Drukk2a=2)NYDRUKKET_12=3.
iF (Drukk2a=3)NYDRUKKET_12=4.
iF (Drukk2b=1)NYDRUKKET_12=4.
iF (Drukk2b=2)NYDRUKKET_12=5.
iF (Drukk2b=3)NYDRUKKET_12=6.
iF (Drukk2b=8)NYDRUKKET_12=99.
iF (Drukk2c=1)NYDRUKKET_12=7.
iF (Drukk2c=2)NYDRUKKET_12=7.
iF (Drukk2c=3)NYDRUKKET_12=8.
iF (Drukk2c=9)NYDRUKKET_12=99.
EXE.


OG DA ANTALL DAGER HER :

RECODENYDRUKKET_12 DRUKKET12_KVASI (1=365) (2=234) (3=130) (4=52) (5=30) (6=12) (7=4) (8=1) into DRUKKET12_KVASI.
EXE.

Husk sett 99= missing.


GJENNOMSNITT FOR 6+ DRIKKING FOM 2015:

setter inn de som IKKE har drukket til  ingen ganger  (DE HAR IKKE FÅTT SPØRSMÅLENE)

 comp AUDIT_KV2=999.

ANTALL DAGER FOR 6 + DA:

IF (Audit3=1) AUDIT_KV2=365.
IF (Audit3=5) AUDIT_KV2=0.
IF (Audit3=8) AUDIT_KV2=99.
IF (Audit3=9) AUDIT_KV2=99.
IF (Audit3_1=1) AUDIT_KV2=234.
IF (Audit3_1=2) AUDIT_KV2=130.
IF (Audit3_1=3) AUDIT_KV2=52.
IF (Audit3_1=8) AUDIT_KV2=99.
IF (Audit3_1=9) AUDIT_KV2=99.
IF (Audit3_2=1) AUDIT_KV2=52.
IF (Audit3_2=2) AUDIT_KV2=30.
IF (Audit3_2=3) AUDIT_KV2=12.
IF (Audit3_2=8) AUDIT_KV2=99.
IF (Audit3_2=9) AUDIT_KV2=99.
IF (Audit3_3=1) AUDIT_KV2=4.
IF (Audit3_3=2) AUDIT_KV2=4.
IF (Audit3_3=3) AUDIT_KV2=1.
IF (Audit3_3=8) AUDIT_KV2=99.
IF (Audit3_3=9) AUDIT_KV2=99.
If (drukket1=2) AUDIT_KV2=0.
EXE.


HUSK Å SETTE 99 OG 999 TIL MISSING ETC.

LAGE AUDIT1******************

Comp Audit1=9999.
exe.

IF (Drukket1=2) Audit1=0.
IF (Drukket2=3) Audit1=1.
if  (Drukket2=4) Audit1=1.
IF (Drukk2b=1) audit1=2.
if (Drukk2b=2) Audit1=2.
IF (Drukk2a=3) Audit1=2.
IF (Drukk2a=2) Audit1=3.
IF (Drukket2=1) Audit1=4.
IF (Drukk2a=1) Audit1=4.
exe.

recode Audit1 (9999=sysmis).

fre Audit1.



fre nyAudit2 nyAudit3 nyAudit4 nyAudit5 nyAudit6 nyAudit7 nyAudit8.

RECODE Audit2 (1=0) (2=1) (3=2) (4=3) (5=4) (8=sysmis) (9=sysmis) INTO NyAUDIT2.
RECODE Audit3 (1=4) (2=3) (3=2) (4=1) (5=0) (8=sysmis) (9=sysmis) INTO NyAUDIT3.
RECODE Audit4 (1=0) (2=1) (3=2) (4=3) (5=4) (8=sysmis) (9=sysmis) INTO NyAUDIT4.
RECODE Audit5 (1=0) (2=1) (3=2) (4=3) (5=4) (8=sysmis) (9=sysmis) INTO NyAUDIT5.
RECODE Audit6 (1=0) (2=1) (3=2) (4=3) (5=4) (8=sysmis) (9=sysmis) INTO NyAUDIT6.
RECODE Audit7 (1=0) (2=1) (3=2) (4=3) (5=4) (8=sysmis) (9=sysmis) INTO NyAUDIT7.
RECODE Audit8 (1=0) (2=1) (3=2) (4=3) (5=4) (8=sysmis) (9=sysmis) INTO NyAUDIT8.
EXECUTE.


fre Audit9 Audit9a Audit10 Audit10a.

HUSK NYE SOM I 2024 FOR DETTE!

IF (Audit9 = 2) NyAUDIT9 = 0 .
IF (Audit9a = 2) NyAUDIT9 = 2 .
IF (Audit9a = 1) NyAUDIT9 = 4 .
exe.

IF (Audit10 = 2) NyAUDIT10 = 0 .
IF (Audit10a = 2) NyAUDIT10 = 2 .
IF (Audit10a = 1) NyAUDIT10 = 4 .
exe.


****Gir alle som aldri drikk skåren 0:



*siste fire uker OG ANTALL DAGER ***


1. Daglig                  30
2. 4-5 ganger i uken       18
3. 2-3 ganger i uken       10
4. Omtrent en gang i uken  4
5. Flere enn 3 dager       3,5
6. 2-3 dager               2,5
6. En gang siste fire uker 1



if (Type1a=1) Kvasi4øl=30.
if (Typ1a_uk=1) Kvasi4øl=18.
if (Typ1a_uk=2) Kvasi4øl=10.
if (Typ1a_uk=3) Kvasi4øl=4.
if (Typ1a_mn=1) Kvasi4øl=3.5.
if (Typ1a_mn=2) Kvasi4øl=2.5.
if (Typ1a_mn=3) Kvasi4øl=1.
if (Drukket3=2) Kvasi4øl=0.
if (Type1=2) Kvasi4øl=0.


fre drukket3.

fre kvasi4øl.


if (Type2a=1) Kvasi4vin=30.
if (Typ2a_uk=1) Kvasi4vin=18.
if (Typ2a_uk=2) Kvasi4vin=10.
if (Typ2a_uk=3) Kvasi4vin=4.
if (Typ2a_mn=1) Kvasi4vin=3.5.
if (Typ2a_mn=2) Kvasi4vin=2.5.
if (Typ2a_mn=3) Kvasi4vin=1.
if (Drukket3=2) Kvasi4vin=0.
if (Type2=2) Kvasi4vin=0.


fre drukket3.

fre kvasi4vin.



if (Type3a=1) Kvasi4brvin=30.
if (Typ3a_uk=1) Kvasi4brvin=18.
if (Typ3a_uk=2) Kvasi4brvin=10.
if (Typ3a_uk=3) Kvasi4brvin=4.
if (Typ3a_mn=1) Kvasi4brvin=3.5.
if (Typ3a_mn=2) Kvasi4brvin=2.5.
if (Typ3a_mn=3) Kvasi4brvin=1.
if (Drukket3=2) Kvasi4brvin=0.
if (Type3=2) Kvasi4brvin=0.


fre drukket3.

fre Kvasi4brvin.



if (Type4a=1) Kvasi4cider=30.
if (Typ4a_uk=1) Kvasi4cider=18.
if (Typ4a_uk=2) Kvasi4cider=10.
if (Typ4a_uk=3) Kvasi4cider=4.
if (Typ4a_mn=1) Kvasi4cider=3.5.
if (Typ4a_mn=2) Kvasi4cider=2.5.
if (Typ4a_mn=3) Kvasi4cider=1.
if (Drukket3=2) Kvasi4cider=0.
if (Type4=2) Kvasi4cider=0.


fre drukket3.

fre Kvasi4cider.
