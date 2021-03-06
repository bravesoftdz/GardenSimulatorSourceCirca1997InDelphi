unit Uaspects;
{Copyright (c) 1997 Paul D. Fernhout and Cynthia F. Kurtz All rights reserved
http://www.gardenwithinsight.com. See the license file for details on redistribution.
=====================================================================================
uaspects: Aspects are objects that hold information about simulation variables in order to
display them in the browser and graph window. Aspects are held by the aspect manager
through which they are accessed by the domain and windows. Aspects are created at
program startup by the domain. Code to create aspects is generated by the supporting program
'tab2asp.exe', which takes the information in the tab-delimited file 'aspects.tab' and creates
six pascal files: uasp_pla (plant), uasp_dpl (drawing plant), uasp_s1,2,3 (soil
patch - in 3 pieces because it was too big to compile), uasp_wea (weather), and umconsts
(constants and transfer functions). The tab2asp program has its own project and source
code (one form file). This system allows the over 800 aspects to be modified in the
tab file more easily (using a spreadsheet to sort and resort the columns to compare)
than editing the source code directly. To add a new aspect, add it to the aspects.tab
file, then run tab2asp, then make sure you add a line to the asphints.tab file to fill
in a hint for the aspect. If you change the ID constant of an aspect, you must change
the ID in the asphints.tab file also. Make sure to always sort the aspects.tab file
by the ID column ONLY when you are finished with it. See the description of the
aspects.tab file at the end of the programmer's guide for explanations of columns
in aspects.tab, which correspond to fields of the GsAspect object.}

interface

uses UFiler, ucollect;

const

	{ ObjectType }
  kObjectUndefined = 0;
  kObjectTypeSoil = 1;
  kObjectTypePlant = 2;
  kObjectTypeWeather = 3;
  kObjectTypeGarden = 4;
  kObjectTypeBlob = 5;
  kObjectTypeFruit = 6;
  kObjectTypePesticide = 7;
  kObjectTypeBag = 8;
  kObjectTypeDrawingPlant = 9;
  kObjectTypeHarvestItemTemplate = 10;
  kObjectType3DObject = 11;
  kObjectTypeIcon = 12;
  kObjectTypeLast = 12;

  { FieldType }
  kFieldUndefined = 0;
  kFieldFloat = 1;
  kFieldInt = 2;
  kFieldUnsignedLong = 3;
  kFieldUnsignedChar = 4;
  kFieldString = 5;
  kFieldFileString = 6;
  kFieldColor = 7;
  kFieldBoolean = 8;
  kFieldIcon = 9;
  kFieldThreeDObject = 10;
  kFieldEnumeratedList = 11;
  kFieldHarvestItemTemplate = 12;

	{ IndexType - for arrays }
  kIndexTypeUndefined = 0;
  kIndexTypeNone = 1;
  kIndexTypeLayer = 2;
  kIndexTypeMonth = 3;
  kIndexTypeSCurve = 4;
  kIndexTypeSoilTextureTriangle = 5;
  kIndexTypeMaleFemale = 6;
  kIndexTypeHarvestItemTypes = 7;
  kIndexTypeWeatherMatrix = 8;
  kIndexTypeMUSICoefficients = 9;

  { aspectType - used only in group editor to choose parameters or variables (all others) }
  kAspectTypeHidden = 0;
  kAspectTypeParameter = 1;
  kAspectTypeStateVar = 2;
  kAspectTypeTotalledVar = 3;
  kAspectTypeOutputVar = 4;

  { boundSource - for reference only to check on bounds }
  kBoundSourceNone = 0;
  kBoundSourceEpic = 1;
  kBoundSourceKfSoft = 2;
  kBoundSourceUnitSet = 3;

  { transferType - how data is transferred to and from model object }
  kTransferTypeUndefined = 0;
  kTransferTypeMFD = 1;  {mfd is short for MoveFieldData}
  kTransferTypeBDConvert = 2;
  kTransferTypeGetSetSCurve = 3;
  kTransferTypeHarvestItemTemplate = 4;
  kTransferTypeObject3D = 5;
  kTransferTypeStorageOrganLumping = 6;
  kTransferTypeHarvestBundling = 7;
  kTransferTypeDerived = 100;

  { deriveMethod - how display data is derived from simulation variable }
  kDeriveTypeUndefined = 0;
  kDeriveTypeDepth = 1;
  kDeriveTypeConcentration = 2;
  kDeriveTypeArea = 3;
  kDeriveTypeConcentrationFromPercent = 4;

  kMaxNumDerivations = 3;

type

unitsAndBoundsInfoType = record
  deriveMethod: smallint; {ignored for the normal units and bounds}
  unitSet: smallint;
  unitModel: smallint;
  unitDefaultMetric: smallint;
  unitDefaultEnglish: smallint;
  boundSoftLower: single;
  boundSoftUpper: single;
  boundHardLower: single;
  boundHardUpper: single;
  boundSource: smallint;
  end;
unitsAndBoundsInfoArrayType = array[0..kMaxNumDerivations] of unitsAndBoundsInfoType;

GsAspect = class(GsStreamableObject)
  public
  fieldID: string[80];
  fieldNumber: longint;
  aspectName: string[80];
  fieldType: smallint;
  indexType: smallint;
  readOnly: boolean;
  aspectType: smallint;
  transferType: smallint;
  accessName: string[80];
  hasHelp: boolean;
  unitsAndBounds: unitsAndBoundsInfoArrayType;
  numUnitsAndBounds: smallint;
  hint: PChar;
  constructor createWithInfo(aFieldID, anAspectName: string;
    aFieldNumber: longint; aFieldType, anIndexType: smallint;
    aReadOnly: boolean; anAspectType, aTransferType: smallint; anAccessName: string; aHasHelp: boolean);
  destructor destroy; override;
  procedure addUnitsAndBounds(aDeriveMethod, aUnitSet, aUnitModel, aUnitMetric, aUnitEnglish: smallint;
    aBoundSL, aBoundSU, aBoundHL, aBoundHU: single; aBoundSource: smallint);
  function copy: GsAspect;
  function objectType: integer;
  function indexCount: integer;
  function canBeDerived: boolean;
  function unitSet(derivedIndex: smallint): smallint;
  function unitModel(derivedIndex: smallint): smallint;
  function unitDefaultMetric(derivedIndex: smallint): smallint;
  function unitDefaultEnglish(derivedIndex: smallint): smallint;
  function boundSoftLower(derivedIndex: smallint): single;
  function boundSoftUpper(derivedIndex: smallint): single;
  function boundHardLower(derivedIndex: smallint): single;
  function boundHardUpper(derivedIndex: smallint): single;
  function deriveMethod(derivedIndex: smallint): smallint;
  end;

GsAspectManager = class(GsStreamableObject)
 	public
  aspects: TListCollection;
  selectedAspectIndex: smallint;
  procedure addAspect(newAspect: GsAspect);
  function newAspect: GsAspect;
  function currentAspect: GsAspect;
  constructor create; override;
  destructor destroy; override;
	class function objectTypeName(objectType: longint): string;
  class function fieldTypeName(fieldType: integer): string;
  class function indexTypeName(indexType: integer): string;
  class function aspectTypeName(aspectType: integer): string;
  class function boundSourceName(boundSource: integer): string;
  function aspectForIndex(index: longint): GsAspect;
  function aspectForFieldID(fieldID: string): GsAspect;
  function aspectForFieldNumber(fieldNumber: longint): GsAspect;
  function aspectIndexForFieldNumber(fieldNumber: longint): integer;
  function aspectIndexForFieldID(fieldID: string): integer;
  procedure readHintsFromFile(aFileName: string);
  procedure saveHintsToFile(aFileName: string);
  end;

implementation

uses SysUtils, uclasses, uexcept, ufilertx;

{ GsAspect }
constructor GsAspect.createWithInfo(aFieldID, anAspectName: string;
    aFieldNumber: longint; aFieldType, anIndexType: smallint;
    aReadOnly: boolean; anAspectType, aTransferType: smallint; anAccessName: string; aHasHelp: boolean);
  begin
  fieldID := aFieldID;
  aspectName := anAspectName;
  fieldNumber := aFieldNumber;
  fieldType := aFieldType;
  indexType := anIndexType;
  readOnly := aReadOnly;
  aspectType := anAspectType;
  transferType := aTransferType;
  accessName := anAccessName;
  hasHelp := aHasHelp;
  hint := nil; {don't allocate hint until it is set}
  end;

destructor GsAspect.destroy;
  begin
  if hint <> nil then StrDispose(hint);
  hint := nil;
  inherited destroy;
  end;

procedure GsAspect.addUnitsAndBounds(aDeriveMethod, aUnitSet, aUnitModel, aUnitMetric, aUnitEnglish: smallint;
    aBoundSL, aBoundSU, aBoundHL, aBoundHU: single; aBoundSource: smallint);
  begin
  inc(numUnitsAndBounds);
  if numUnitsAndBounds > kMaxNumDerivations + 1 then
    raise Exception.create('GsAspect.addUnitsAndBounds: too many derivations');
  with unitsAndBounds[numUnitsAndBounds-1] do
    begin
    deriveMethod := aDeriveMethod;
    unitSet := aUnitSet;
    unitModel := aUnitModel;
    unitDefaultMetric := aUnitMetric;
    unitDefaultEnglish := aUnitEnglish;
    boundSoftLower := aBoundSL;
    boundSoftUpper := aBoundSU;
    boundHardLower := aBoundHL;
    boundHardUpper := aBoundHU;
    boundSource := aBoundSource;
    end;
  end;

function GsAspect.copy: GsAspect;
  begin
  result := GsAspect.create;
  result.fieldID := fieldID;
  result.fieldNumber := fieldNumber;
  result.aspectName := aspectName;
  result.fieldType := fieldType;
  result.indexType := indexType;
  result.readOnly := readOnly;
  result.aspectType := aspectType;
  result.transferType := transferType;
  result.accessName := accessName;
  result.hasHelp := hasHelp;
  result.unitsAndBounds := unitsAndBounds;
  { copy hint PChar - assume copy is a new object and has no hint PChar already }
  result.hint := StrAlloc(sizeOf(hint));
  FailNilPtr(result.hint);
  strCopy(result.hint, hint);
	end;

function GsAspect.canBeDerived: boolean;
  begin
  result := numUnitsAndBounds > 1;
  end;

function GsAspect.deriveMethod(derivedIndex: smallint): smallint;
  begin
  result := 0;
  if (derivedIndex < 0) or (derivedIndex > kMaxNumDerivations) then
    raise Exception.create('GsAspect.unitSet: bad derivedIndex');
  if derivedIndex > numUnitsAndBounds - 1 then exit;
  result := unitsAndBounds[derivedIndex].deriveMethod;
  end;

function GsAspect.unitSet(derivedIndex: smallint): smallint;
  begin
  result := 0;
  if (derivedIndex < 0) or (derivedIndex > kMaxNumDerivations) then
    raise Exception.create('GsAspect.unitSet: bad derivedIndex');
  if derivedIndex > numUnitsAndBounds - 1 then exit;
  result := unitsAndBounds[derivedIndex].unitSet;
  end;

function GsAspect.unitModel(derivedIndex: smallint): smallint;
  begin
  result := 0;
  if (derivedIndex < 0) or (derivedIndex > kMaxNumDerivations) then
    raise Exception.create('GsAspect.unitModel: bad derivedIndex');
  if derivedIndex > numUnitsAndBounds - 1 then exit;
  result := unitsAndBounds[derivedIndex].unitModel;
  end;

function GsAspect.unitDefaultMetric(derivedIndex: smallint): smallint;
  begin
  result := 0;
  if (derivedIndex < 0) or (derivedIndex > kMaxNumDerivations) then
    raise Exception.create('GsAspect.unitDefaultMetric: bad derivedIndex');
  if derivedIndex > numUnitsAndBounds - 1 then exit;
  result := unitsAndBounds[derivedIndex].unitDefaultMetric;
  end;

function GsAspect.unitDefaultEnglish(derivedIndex: smallint): smallint;
  begin
  result := 0;
  if (derivedIndex < 0) or (derivedIndex > kMaxNumDerivations) then
    raise Exception.create('GsAspect.unitDefaultEnglish: bad derivedIndex');
  if derivedIndex > numUnitsAndBounds - 1 then exit;
  result := unitsAndBounds[derivedIndex].unitDefaultEnglish;
  end;

function GsAspect.boundSoftLower(derivedIndex: smallint): single;
  begin
  result := 0.0;
  if (derivedIndex < 0) or (derivedIndex > kMaxNumDerivations) then
    raise Exception.create('GsAspect.boundSoftLower: bad derivedIndex');
  if derivedIndex > numUnitsAndBounds - 1 then exit;
  result := unitsAndBounds[derivedIndex].boundSoftLower;
  end;

function GsAspect.boundSoftUpper(derivedIndex: smallint): single;
  begin
  result := 0.0;
  if (derivedIndex < 0) or (derivedIndex > kMaxNumDerivations) then
    raise Exception.create('GsAspect.boundSoftUpper: bad derivedIndex');
  if derivedIndex > numUnitsAndBounds - 1 then exit;
  result := unitsAndBounds[derivedIndex].boundSoftUpper;
  end;

function GsAspect.boundHardLower(derivedIndex: smallint): single;
  begin
  result := 0.0;
  if (derivedIndex < 0) or (derivedIndex > kMaxNumDerivations) then
    raise Exception.create('GsAspect.boundHardLower: bad derivedIndex');
  if derivedIndex > numUnitsAndBounds - 1 then exit;
  result := unitsAndBounds[derivedIndex].boundHardLower;
  end;

function GsAspect.boundHardUpper(derivedIndex: smallint): single;
  begin
  result := 0.0;
  if (derivedIndex < 0) or (derivedIndex > kMaxNumDerivations) then
    raise Exception.create('GsAspect.boundHardUpper: bad derivedIndex');
  if derivedIndex > numUnitsAndBounds - 1 then exit;
  result := unitsAndBounds[derivedIndex].boundHardUpper;
  end;

function GsAspect.objectType: integer;
  begin
  if pos('kSoilPatch', fieldID) <> 0 then
    result := kObjectTypeSoil
  else if pos('kPlantZZDraw', fieldID) <> 0 then
    result := kObjectTypeDrawingPlant
  else if pos('kPlant', fieldID) <> 0 then
    result := kObjectTypePlant
  else if pos('kWeather', fieldID) <> 0 then
    result := kObjectTypeWeather
  else if pos('kGarden', fieldID) <> 0 then
    result := kObjectTypeGarden
  else if pos('kBag', fieldID) <> 0 then
    result := kObjectTypeBag
  else
    result := 0;
  end;

function GsAspect.indexCount: integer;
  begin
  result := 1;
  case indexType of
    kIndexTypeUndefined: result := 1;
    kIndexTypeNone: result := 1;
    kIndexTypeLayer: result := 10;
    kIndexTypeMonth: result := 12;
    kIndexTypeSCurve: result := 4;
    kIndexTypeSoilTextureTriangle: result := 3;
    kIndexTypeMaleFemale: result := 2;
    kIndexTypeHarvestItemTypes: result := 12;
    kIndexTypeWeatherMatrix: result := 3;
    kIndexTypeMUSICoefficients: result := 4;
  else
    raise Exception.create('GsAspect.indexCount: unexpected index type');
  end;
  end;

{ GsAspectManager }
constructor GsAspectManager.create;
  begin
  inherited create;
  aspects := TListCollection.create;
  end;

destructor GsAspectManager.destroy;
	begin
  aspects.free;
  inherited destroy;
  end;

function GsAspectManager.currentAspect: GsAspect;
	begin
  if (selectedAspectIndex = -1) or (selectedAspectIndex >= aspects.count) then
    result := nil
  else
  	result := GsAspect(aspects.items[selectedAspectIndex]);
  end;

procedure GsAspectManager.addAspect(newAspect: GsAspect);
	begin
  aspects.add(newAspect);
  end;

function GsAspectManager.newAspect: GsAspect;
	var
  theAspect: GsAspect;
	begin
  theAspect := GsAspect.create;
  aspects.add(theAspect);
  selectedAspectIndex := aspects.count - 1;
  result := theAspect;
  end;

class function GsAspectManager.objectTypeName(objectType: longint): string;
	begin
  case objectType of
		kObjectUndefined: result := 'Undefined';
  	kObjectTypeGarden: result := 'Garden';
		kObjectTypeWeather: result := 'Weather';
		kObjectTypeSoil: result := 'Soil Patch';
		kObjectTypePlant: result :='Plant';
		kObjectTypeBlob: result := 'Blob';
		kObjectTypeFruit: result := 'Fruit';
		kObjectTypePesticide: result := 'Pesticide';
    kObjectTypeBag: result := 'Bag';
    kObjectTypeDrawingPlant: result := 'Drawing Plant';
  else
  	result := '<ERROR>';
  end;
  end;

class function GsAspectManager.fieldTypeName(fieldType: integer): string;
  begin
  case fieldType of
    kFieldUndefined: result := 'Undefined';
    kFieldFloat: result := 'Single';
    kFieldInt: result := 'Integer';
    kFieldUnsignedLong: result := 'Longint';
    kFieldUnsignedChar: result := 'Char';
    kFieldString: result := 'String';
    kFieldFileString: result := 'File String';
    kFieldColor: result := 'Color';
    kFieldBoolean: result := 'Boolean';
    kFieldIcon: result := 'Icon';
    kFieldThreeDObject: result := '3D object';
    kFieldEnumeratedList: result := 'List of choices';
    kFieldHarvestItemTemplate: result := 'Harvest item template';
    else result := 'not in list';
    end;
  end;

class function GsAspectManager.indexTypeName(indexType: integer): string;
  begin
  case indexType of
    kIndexTypeUndefined: result := 'Undefined';
    kIndexTypeNone: result := 'None';
    kIndexTypeLayer: result := 'Layer';
    kIndexTypeMonth: result := 'Month';
    kIndexTypeSCurve: result := 'S curve';
    kIndexTypeSoilTextureTriangle: result := 'Soil texture triangle';
    kIndexTypeMaleFemale: result := 'Male/female';
    kIndexTypeHarvestItemTypes: result := 'Harvest item types';
    else result := 'not in list';
    end;
  end;

class function GsAspectManager.aspectTypeName(aspectType: integer): string;
  begin
  case aspectType of
    kAspectTypeHidden: result := 'Hidden';
    kAspectTypeParameter: result := 'Parameter';
    kAspectTypeStateVar: result := 'State variable';
    kAspectTypeTotalledVar: result := 'Totalled variable';
    kAspectTypeOutputVar: result := 'Output variable';
    end;
  end;

class function GsAspectManager.boundSourceName(boundSource: integer): string;
  begin
  case boundSource of
    kBoundSourceNone: result := 'No source';
    kBoundSourceEpic: result := 'Epic';
    kBoundSourceKfSoft: result := 'KfSoft';
    kBoundSourceUnitSet: result := 'Unit set';
    end;
  end;

function GsAspectManager.aspectForIndex(index: longint): GsAspect;
	begin
  result := aspects.items[index];
  end;

function GsAspectManager.aspectForFieldNumber(fieldNumber: longint): GsAspect;
  var
  i: integer;
  aspect: GsAspect;
  begin
  result := nil;
  if aspects.count > 0 then
    for i := 0 to aspects.count - 1 do
      begin
      aspect := GsAspect(aspects.items[i]);
      if fieldNumber = aspect.fieldNumber then
        begin
        result := aspect;
        exit;
        end;
      end;
  raise Exception.create('Aspect not found for field number ' + intToStr(fieldNumber));
  end;

function GsAspectManager.aspectForFieldID(fieldID: string): GsAspect;
  var
  i: integer;
  aspect: GsAspect;
  begin
  result := nil;
  if aspects.count > 0 then
    for i := 0 to aspects.count - 1 do
      begin
      aspect := GsAspect(aspects.items[i]);
      if fieldID = aspect.fieldID then
        begin
        result := aspect;
        exit;
        end;
      end;
  raise Exception.create('Aspect not found for field ID ' + fieldID);
  end;

function GsAspectManager.aspectIndexForFieldNumber(fieldNumber: longint): integer;
  var
  i: integer;
  aspect: GsAspect;
  begin
  result := 0;
  if aspects.count > 0 then
    for i := 0 to aspects.count - 1 do
      begin
      aspect := GsAspect(aspects.items[i]);
      if fieldNumber = aspect.fieldNumber then
        begin
        result := i;
        exit;
        end;
      end;
  raise Exception.create('Aspect index not found for field number ' + intToStr(fieldNumber));
  end;

function GsAspectManager.aspectIndexForFieldID(fieldID: string): integer;
  var
  i: integer;
  aspect: GsAspect;
  begin
  result := 0;
  if aspects.count > 0 then
    for i := 0 to aspects.count - 1 do
      begin
      aspect := GsAspect(aspects.items[i]);
      if fieldID = aspect.fieldID then
        begin
        result := i;
        exit;
        end;
      end;
  raise Exception.create('Aspect index not found for field ID ' + fieldID);
  end;

function trimQuotesFromFirstAndLast(theString: string): string;
  var
    i: smallint;
  begin
  result := theString;
  if result[1] = '"' then
    result := copy(result, 2, length(result) - 1);
  if result[length(result)] = '"' then dec(result[0]);
  end;

procedure GsAspectManager.readHintsFromFile(aFileName: string);
  var
    textFiler: GsTextFiler;
    aspect: GsAspect;
    fieldID, name, aspectHint: string;
    i: longint;
  begin
  textFiler := GsTextFiler.createWithFileNameForReading(aFileName);
  try
  textFiler.skipRestOfLine; {skip labels line}
  while not textFiler.atEndOfFile do
    begin
    textFiler.streamString(fieldID, '');
    textFiler.streamString(name, '');
    aspect := nil;
    if aspects.count > 0 then
      for i := 0 to aspects.count - 1 do
        if fieldID = GsAspect(aspects.items[i]).fieldID then
          begin
          aspect := GsAspect(aspects.items[i]);
          break;
          end;
    if aspect <> nil then
      begin
      if (name <> aspect.aspectName) and (name <> '') and (name <> '(none)') then
        aspect.aspectName := copy(trimQuotesFromFirstAndLast(name), 1, 80);
      textFiler.streamPChar(aspect.hint, '');
      end
    else
      textFiler.skipRestOfLine;
    end;
  finally
    textFiler.free;
  end;
  end;

{this procedure was used for development for making new files for filling in aspect hints. no longer used.}
procedure GsAspectManager.saveHintsToFile(aFileName: string);
  var
    aspect: GsAspect;
    i: longint;
    aspectHint, aspectName: string;
    outputFile: TextFile;
  begin
  try
    assignFile(outputFile, aFileName);
    rewrite(outputFile);
    writeln(outputFile, 'fieldID' + chr(9) + 'name' + chr(9) + 'hint');
    if aspects.count > 0 then
      for i := 0 to aspects.count - 1 do
        begin
        aspect := GsAspect(aspects.items[i]);
        if aspect = nil then continue;
        write(outputFile, aspect.fieldID + chr(9) + aspect.aspectName + chr(9));
        if aspect.hint <> nil then
          begin
          aspectHint := strPas(aspect.hint);
          write(outputFile, aspectHint);
          end
        else 
          write(outputFile, '(none)');
        writeln(outputFile);
        end;
  finally
    closeFile(outputFile);
  end;
  end;

end.


