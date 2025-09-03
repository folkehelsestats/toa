Øl:
recode  Type1b_1 Type1b_2 Type1c_1 Type1c_2  (99998=sysmis) (99999=sysmis).
COMPUTE UnitsØL_033UK=(Type1b_1*4).
COMPUTE  UnitsØL_050UK=(Type1b_2*1.5*4).
COMPUTE UnitsØL_033MND=(Type1c_1).
COMPUTE UnitsØL_050MND=(Type1c_2*1.5).

recode UnitsØL_033UK UnitsØL_050UK UnitsØL_033MND UnitsØL_050MND (sysmis=0).

COMPUTE Unitsøltot_s4=sum(UnitsØL_033UK,UnitsØL_050UK,UnitsØL_033MND,UnitsØL_050MND).

Vin:
recode  Type2b_1 Type2b_2 Type2c_1 Type2c_2 (99998=sysmis) (99999=sysmis).

COMPUTE UnitsVIN_015UK=(Type2b_1*1.2*4).
COMPUTE UnitsVIN_075UK=(Type2b_2*6*4).
COMPUTE UnitsVIN_015MND=(Type2c_1*1.2).
COMPUTE UnitsVIN_075MND=(Type2c_2*6).

recode unitsVIN_015UK unitsVIN_075UK unitsVIN_015MND unitsVIN_075MND  (sysmis=0).
exe.
COMPUTE UnitsVINtot_s4= sum(UnitsVIN_015UK,UnitsVIN_075UK, UnitsVIN_015MND, UnitsVIN_075MND).

Brennevin:
recode  Type3b_1 Type3b_2 Type3c_1 Type3c_2 (99998=sysmis) (99999=sysmis).

COMPUTE UnitsBRVIN_004UK=(Type3b_1*4).
COMPUTE UnitsBRVIN_070UK=(Type3b_2*17.5*4).
COMPUTE UnitsBRVIN_004MND=(Type3c_1).
COMPUTE UnitsBRVIN_070MND=(Type3c_2*17.5).
recode UnitsBRVIN_004UK UnitsBRVIN_070UK UnitsBRVIN_004MND UnitsBRVIN_070MND (sysmis=0).
COMPUTE UnitsBRVINtot_s4= sum(UnitsBRVIN_004UK,UnitsBRVIN_070UK,UnitsBRVIN_004MND,UnitsBRVIN_070MND).

Rusbrus/Cider
recode  Type4b_1 Type4b_2 Type4c_1 Type4c_2 (99998=sysmis) (99999=sysmis).

COMPUTE UnitsRUSBR_033UK=(Type4b_1*4).
COMPUTE UnitsRUSBR_050UK=(Type4b_2*1.50*4).
COMPUTE UnitsRUSBR_033MND=(Type4c_1).
COMPUTE UnitsRUSBR_050MND=(Type4c_2*1.50).
exe.

recode UnitsRUSBR_033UK UnitsRUSBR_050UK UnitsRUSBR_033MND UnitsRUSBR_050MND  (sysmis=0).
COMPUTE UnitsRUSBRtot_s4=sum(UnitsRUSBR_033UK,UnitsRUSBR_050UK,UnitsRUSBR_033MND,UnitsRUSBR_050MND).

TOTALT
comp sumEnheter=sum(Unitsøltot_s4,UnitsVINtot_s4,UnitsBRVINtot_s4,UnitsRUSBRtot_s4).
If (sumEnheter>70) sumEnheter=70.
