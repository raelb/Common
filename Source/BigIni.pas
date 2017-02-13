unit BigIni;

interface

uses
  System.Classes, Winapi.Windows, Winapi.ShellAPI, System.SysUtils, Vcl.Forms, Vcl.Graphics;

const
  IniTextBufferSize = $7000; { Note [1]: don't use more than $7FFF - it's an integer }

type
  TEraseSectionCallback = function(const sectionName: string; const sl1, sl2: TStringList): Boolean of object;

  TSectionList = class(TStringList)
  private
    FPrevIndex: Integer;
  public
    constructor Create;
    function EraseDuplicates(callBackProc: TEraseSectionCallback = nil): Boolean;
    function GetSectionItems(Index: Integer): TStringList;
    function IndexOf(const AValue: string): Integer; override;
    function IndexOfName(const AName: string): Integer; override;
    property SectionItems[AIndex: Integer]: TStringList read GetSectionItems;
  end;

  TBigIniFile = class(TObject)
  protected
    FHasChanged: Boolean;
    FTextBufferSize: Integer;
  private
    FEraseSectionCallback: TEraseSectionCallback;
    FFileName: string;
    FPrevSectionIndex: Integer;
    FFlagClearOnReadSectionValues,
    FFlagDropCommentLines,
    FFlagFilterOutInvalid,
    FFlagDropWhiteSpace,
    FFlagDropApostrophes,
    FFlagTrimRight: Boolean;
    FSectionList: TSectionList;
    function FindItemIndex(const ASection, AKey: string; CreateNew: Boolean; var FoundStringList: TStringList): Integer;
    procedure SetFileName(const aName: string);
    procedure ClearSectionList;
  public
    constructor Create(const FileName: string);
    destructor Destroy; override;

    function ReadBool(const ASection, AKey: string; aDefault: Boolean): Boolean; virtual;
    function ReadDate(const ASection, AKey: string; aDefault: TDateTime): TDateTime; virtual;
    function ReadDateTime(const ASection, AKey: string; aDefault: TDateTime): TDateTime; virtual;
    function ReadFloat(const ASection, AKey: string; aDefault: Double): Double; virtual;
    function ReadInteger(const ASection, AKey: string; aDefault: Longint): Longint; virtual;
    function ReadString(const ASection, AKey, aDefault: string): string; virtual;
    function ReadTime(const ASection, AKey: string; aDefault: TDateTime): TDateTime; virtual;
    function SectionExists(const ASection: string): Boolean; virtual;
    function ValueExists(const ASection, AKey: string): Boolean; virtual;
    procedure AppendFromFile(const aName: string); virtual;
    procedure Clear; virtual;
    procedure DeleteKey(const ASection, AKey: string); virtual;
    procedure EraseSection(const ASection: string); virtual;
    procedure FlushFile; virtual;
    procedure GetStrings(List: TStrings); virtual;
    procedure ReadSection(const ASection: string; aStrings: TStrings); virtual;
    procedure ReadSections(aStrings: TStrings); virtual;
    procedure ReadSectionValues(const ASection: string; aStrings: TStrings); virtual;
    procedure SetStrings(const aStrings: TStrings); virtual;
    procedure UpdateFile; virtual;
    procedure WriteBool(const ASection, AKey: string; AValue: Boolean); virtual;
    procedure WriteDate(const ASection, AKey: string; AValue: TDateTime); virtual;
    procedure WriteDateTime(const ASection, AKey: string; AValue: TDateTime); virtual;
    procedure WriteFloat(const ASection, AKey: string; AValue: Double); virtual;
    procedure WriteInteger(const ASection, AKey: string; AValue: Longint); virtual;
    procedure WriteString(const ASection, AKey, AValue: string); virtual;
    procedure WriteTime(const ASection, AKey: string; AValue: TDateTime); virtual;
    property EraseSectionCallback: TEraseSectionCallback read FEraseSectionCallback write FEraseSectionCallback;
    property FileName: string read FFileName write SetFileName;
    property FlagClearOnReadSectionValues: Boolean read FFlagClearOnReadSectionValues write FFlagClearOnReadSectionValues;
    property FlagDropApostrophes: Boolean read FFlagDropApostrophes write FFlagDropApostrophes;
    property FlagDropCommentLines: Boolean read FFlagDropCommentLines write FFlagDropCommentLines;
    property FlagDropWhiteSpace: Boolean read FFlagDropWhiteSpace write FFlagDropWhiteSpace;
    property FlagFilterOutInvalid: Boolean read FFlagFilterOutInvalid write FFlagFilterOutInvalid;
    property FlagTrimRight: Boolean read FFlagTrimRight write FFlagTrimRight;
  end;

implementation

uses
  System.UITypes;

constructor TSectionList.Create;
begin
  inherited Create;

  FPrevIndex := 0;
end;

function TSectionList.GetSectionItems(Index: Integer): TStringList;
begin
  Result := TStringList(Objects[Index]);
end;

function TSectionList.EraseDuplicates(callBackProc: TEraseSectionCallback = nil): Boolean;
var
  LStringListDuplicateTracking: TStringList;
  LIndextoDelete, LIndexLow, LIndexHigh, LIndex: Integer;

  procedure SwapInt(var AValue1, AValue2: Integer);
  var
    LTemp: Integer;
  begin
    LTemp := AValue1;
    AValue1 := AValue2;
    AValue2 := LTemp;
  end;

begin
  Result := False;

  if Count > 1 then
  begin
    LStringListDuplicateTracking := TStringList.Create;
    LStringListDuplicateTracking.Assign(Self);
    for LIndex := 0 to LStringListDuplicateTracking.Count - 1 do
      LStringListDuplicateTracking.Objects[LIndex] := Pointer(LIndex);
    LStringListDuplicateTracking.Sort;
    LIndexLow := 0;
    for LIndex := 1 to LStringListDuplicateTracking.Count - 1 do
    begin
      if (AnsiCompareText(LStringListDuplicateTracking.Strings[LIndexLow], LStringListDuplicateTracking.Strings[LIndex]) <> 0) then
      begin
        LIndexLow := LIndex;
      end
      else
      begin
        LIndexHigh := LIndex;
        if Integer(LStringListDuplicateTracking.Objects[LIndexLow]) > Integer(LStringListDuplicateTracking.Objects[LIndexHigh]) then
          SwapInt(LIndexHigh, LIndexLow);

        if Assigned(callBackProc) then
          if not callBackProc(LStringListDuplicateTracking.Strings[LIndex], SectionItems[Integer(LStringListDuplicateTracking.Objects[LIndexLow])
            ], SectionItems[Integer(LStringListDuplicateTracking.Objects[LIndexHigh])]) then
            SwapInt(LIndexHigh, LIndexLow);
        LIndextoDelete := Integer(LStringListDuplicateTracking.Objects[LIndexHigh]);

        SectionItems[LIndextoDelete].Free;
        Objects[LIndextoDelete] := nil;
        Result := True;
      end;
    end;

    LIndex := 0;
    while LIndex < Count do
    begin
      if Objects[LIndex] = nil then
        Delete(LIndex)
      else
        Inc(LIndex);
    end;
    LStringListDuplicateTracking.Free;
  end;
end;

function TSectionList.IndexOf(const AValue: string): Integer;
var
  LIndex, LIndexLast: Integer;
begin
  Result := -1;
  if Count = 0 then
    Exit;

  LIndexLast := FPrevIndex;
  for LIndex := LIndexLast to Count - 1 do
  begin
    if AnsiCompareText(Get(LIndex), AValue) = 0 then
    begin
      Result := LIndex;
      FPrevIndex := LIndex;
      Exit;
    end;
  end;
  for LIndex := 0 to LIndexLast - 1 do
  begin
    if AnsiCompareText(Get(LIndex), AValue) = 0 then
    begin
      Result := LIndex;
      FPrevIndex := LIndex;
      Exit;
    end;
  end;
end;

function TSectionList.IndexOfName(const AName: string): Integer;
var
  P: Integer;
  s1, s2: string;
begin
  s2 := AName;
  for Result := 0 to GetCount - 1 do
  begin
    s1 := Get(Result);
    P := Pos('=', s1);
    SetLength(s1, P - 1);
    if (P <> 0) and (CompareString(LOCALE_USER_DEFAULT, NORM_IGNORECASE, PChar(s1), -1, PChar(s2), -1) = 2) then
      Exit;
  end;
  Result := -1;
end;

constructor TBigIniFile.Create(const FileName: string);
begin
  FSectionList := TSectionList.Create;
  FTextBufferSize := IniTextBufferSize;
  FFlagDropCommentLines := False;
  FFlagFilterOutInvalid := False;
  FFlagDropWhiteSpace := False;
  FFlagDropApostrophes := False;
  FFlagTrimRight := False;
  FFlagClearOnReadSectionValues := False;
  FFileName := '';
  FPrevSectionIndex := 0;
  FEraseSectionCallback := nil;
  SetFileName(FileName);
end;

destructor TBigIniFile.Destroy;
begin
  FlushFile;
  ClearSectionList;
  FSectionList.Free;
  inherited Destroy;
end;

procedure TBigIniFile.ClearSectionList;
var
  ixSections: Integer;
begin
  with FSectionList do
  begin
    for ixSections := 0 to Count - 1 do
    begin
      SectionItems[ixSections].Free;
    end;
    Clear;
    FPrevIndex := 0;
  end;
end;

procedure TBigIniFile.Clear;
begin
  ClearSectionList;
end;

procedure TBigIniFile.AppendFromFile(const aName: string);
var
  CurrStringList: TStringList;
  CurrSectionName: string;
  lpTextBuffer: Pointer;
  Source: TextFile;
  OneLine: string;
  LL: Integer;
  LastPos, EqPos: Integer;
  nospace: Boolean;
begin
  CurrStringList := nil;
  lpTextBuffer := nil;
  FPrevSectionIndex := 0;
  if FileExists(aName) then
  begin
    Assign(Source, aName);
    if FTextBufferSize > 0 then
    begin
      GetMem(lpTextBuffer, FTextBufferSize);
      SetTextBuf(Source, lpTextBuffer^, FTextBufferSize);
    end;
    Reset(Source);
    while NOT Eof(Source) do
    begin
      ReadLn(Source, OneLine);
      if OneLine = #$1A { EOF } then
        OneLine := '';
      if FFlagDropCommentLines then
        if (OneLine <> '') then
          if (OneLine[1] = ';') then
            OneLine := '';
      if OneLine <> '' then
      begin
        LL := Length(OneLine);
        if (OneLine[1] = '[') AND (OneLine[LL] = ']') then
        begin
          CurrSectionName := Copy(OneLine, 2, LL - 2);
          CurrStringList := TStringList.Create;
          FSectionList.AddObject(CurrSectionName, CurrStringList);
        end
        else
        begin
          if FFlagDropWhiteSpace then
          begin
            nospace := False;
            repeat
              EqPos := AnsiPos('=', OneLine);
              if EqPos > 1 then
              begin
                if CharInSet(OneLine[EqPos - 1], [' ', #9]) then
                  Delete(OneLine, EqPos - 1, 1)
                else
                  nospace := True;
              end
              else
                nospace := True;
            until nospace;
            nospace := False;
            EqPos := AnsiPos('=', OneLine);
            if EqPos > 1 then
            begin
              repeat
                if EqPos < Length(OneLine) then
                begin
                  if CharInSet(OneLine[EqPos + 1], [' ', #9]) then
                    Delete(OneLine, EqPos + 1, 1)
                  else
                    nospace := True;
                end
                else
                  nospace := True;
              until nospace;
            end;
          end;
          if FFlagDropApostrophes then
          begin
            EqPos := AnsiPos('=', OneLine);
            if EqPos > 1 then
            begin
              LL := Length(OneLine);
              if EqPos < LL - 1 then
              begin
                if (OneLine[EqPos + 1] = OneLine[LL]) and CharInSet(OneLine[LL], ['"', #39]) then
                begin
                  Delete(OneLine, LL, 1);
                  Delete(OneLine, EqPos + 1, 1);
                end;
              end;
            end;
          end;
          if FFlagTrimRight then
          begin
            LastPos := Length(OneLine);
            while (LastPos > 0) and (OneLine[LastPos] < #33) do
              Dec(LastPos);
            OneLine := Copy(OneLine, 1, LastPos);
          end;
          if not FFlagFilterOutInvalid or (AnsiPos('=', OneLine) > 0) then
          begin
            if Assigned(CurrStringList) then
              CurrStringList.Add(OneLine);
          end;
        end;
      end;
    end;

    if FSectionList.EraseDuplicates(FEraseSectionCallback) then
      FHasChanged := True;

    Close(Source);
    if FTextBufferSize > 0 then
    begin
      FreeMem(lpTextBuffer, FTextBufferSize);
    end;
  end;
end;

procedure TBigIniFile.SetFileName(const aName: string);
begin
  FlushFile;
  ClearSectionList;
  FFileName := aName;
  if aName <> '' then
    AppendFromFile(aName);
  FHasChanged := False;
end;

function TBigIniFile.FindItemIndex(const ASection, AKey: string; CreateNew: Boolean;
  var FoundStringList: TStringList): Integer;
var
  SectionIndex: Integer;
  LastIX: Integer;
begin
  SectionIndex := -1;

  if FSectionList.Count > 0 then
  begin
    LastIX := FPrevSectionIndex - 1;
    if LastIX < 0 then
      LastIX := FSectionList.Count - 1;
    while (AnsiCompareText(ASection, FSectionList[FPrevSectionIndex]) <> 0) AND (FPrevSectionIndex <> LastIX) do
    begin
      Inc(FPrevSectionIndex);
      if FPrevSectionIndex = FSectionList.Count then
        FPrevSectionIndex := 0;
    end;
    if AnsiCompareText(ASection, FSectionList[FPrevSectionIndex]) = 0 then
    begin
      SectionIndex := FPrevSectionIndex;
    end;
  end;

  if SectionIndex = -1 then
  begin
    if CreateNew then
    begin
      FoundStringList := TStringList.Create;
      FPrevSectionIndex := FSectionList.AddObject(ASection, FoundStringList);
    end
    else
    begin
      FoundStringList := nil;
    end;
    Result := -1;
  end
  else
  begin
    FoundStringList := FSectionList.SectionItems[SectionIndex];
    Result := FoundStringList.IndexOfName(AKey);
  end;
end;

function TBigIniFile.ReadString(const ASection, AKey, aDefault: string): string;
var
  ItemIndex: Integer;
  CurrStringList: TStringList;
begin
  ItemIndex := FindItemIndex(ASection, AKey, False, CurrStringList);
  if ItemIndex = -1 then
  begin
    Result := aDefault
  end
  else
  begin
    Result := Copy(CurrStringList[ItemIndex], Length(AKey) + 2, MaxInt);
  end;
end;

procedure TBigIniFile.WriteString(const ASection, AKey, AValue: string);
var
  ItemIndex: Integer;
  CurrStringList: TStringList;
  newLine: string;
begin
  if AKey = '' then
  begin
    if (ASection = '') AND (AValue = '') then
      FlushFile
    else
      EraseSection(ASection);
  end
  else
  begin
    newLine := AKey + '=' + AValue;
    ItemIndex := FindItemIndex(ASection, AKey, True, CurrStringList);
    if ItemIndex = -1 then
    begin
      CurrStringList.Add(newLine);
      FHasChanged := True;
    end
    else
    begin
      if (CurrStringList[ItemIndex] <> newLine) then
      begin
        FHasChanged := True;
        CurrStringList[ItemIndex] := newLine;
      end;
    end;
  end;
end;

function TBigIniFile.ReadInteger(const ASection, AKey: string; aDefault: Longint): Longint;
var
  IStr: string;
begin
  IStr := ReadString(ASection, AKey, '');
  if CompareText(Copy(IStr, 1, 2), '0x') = 0 then
    IStr := '$' + Copy(IStr, 3, 255);
  Result := StrToIntDef(IStr, aDefault);
end;

procedure TBigIniFile.WriteInteger(const ASection, AKey: string; AValue: Longint);
begin
  WriteString(ASection, AKey, IntToStr(AValue));
end;

function TBigIniFile.ReadBool(const ASection, AKey: string; aDefault: Boolean): Boolean;
var
  IStr: string;
begin
  IStr := ReadString(ASection, AKey, '');
  if (IStr = 'True') or (IStr = '1') then
    Result := True
  else
    if (IStr = 'False') or (IStr = '0') then
      Result := False
    else
      Result := aDefault;
end;

procedure TBigIniFile.WriteBool(const ASection, AKey: string; AValue: Boolean);
begin
  WriteString(ASection, AKey, BoolToStr(AValue, True));
end;

function TBigIniFile.ReadDate(const ASection, AKey: string; aDefault: TDateTime): TDateTime;
var
  DateStr: string;
begin
  DateStr := ReadString(ASection, AKey, '');
  Result := aDefault;
  if DateStr <> '' then
    try
      Result := StrToDate(DateStr);
    except
      on EConvertError do
      else
        raise;
    end;
end;

procedure TBigIniFile.WriteDate(const ASection, AKey: string; AValue: TDateTime);
begin
  WriteString(ASection, AKey, DateToStr(AValue));
end;

function TBigIniFile.ReadDateTime(const ASection, AKey: string; aDefault: TDateTime): TDateTime;
var
  DateStr: string;
begin
  DateStr := ReadString(ASection, AKey, '');
  Result := aDefault;
  if DateStr <> '' then
    try
      Result := StrToDateTime(DateStr);
    except
      on EConvertError do
      else
        raise;
    end;
end;

procedure TBigIniFile.WriteDateTime(const ASection, AKey: string; AValue: TDateTime);
begin
  WriteString(ASection, AKey, DateTimeToStr(AValue));
end;

function TBigIniFile.ReadFloat(const ASection, AKey: string; aDefault: Double): Double;
var
  FloatStr: string;
begin
  FloatStr := ReadString(ASection, AKey, '');
  Result := aDefault;
  if FloatStr <> '' then
    try
      Result := StrToFloat(FloatStr);
    except
      on EConvertError do
      else
        raise;
    end;
end;

procedure TBigIniFile.WriteFloat(const ASection, AKey: string; AValue: Double);
begin
  WriteString(ASection, AKey, FloatToStr(AValue));
end;

function TBigIniFile.ReadTime(const ASection, AKey: string; aDefault: TDateTime): TDateTime;
var
  TimeStr: string;
begin
  TimeStr := ReadString(ASection, AKey, '');
  Result := aDefault;
  if TimeStr <> '' then
    try
      Result := StrToTime(TimeStr);
    except
      on EConvertError do
      else
        raise;
    end;
end;

procedure TBigIniFile.WriteTime(const ASection, AKey: string; AValue: TDateTime);
begin
  WriteString(ASection, AKey, TimeToStr(AValue));
end;

procedure TBigIniFile.ReadSection(const ASection: string; aStrings: TStrings);
var
  SectionIndex: Integer;
  CurrStringList: TStringList;
  ix: Integer;
begin
  SectionIndex := FSectionList.IndexOf(ASection);
  if SectionIndex <> -1 then
  begin
    aStrings.BeginUpdate;
    CurrStringList := FSectionList.SectionItems[SectionIndex];
    for ix := 0 to CurrStringList.Count - 1 do
    begin
      if CurrStringList.Names[ix] = '' then
        Continue;
      if FFlagDropCommentLines AND (CurrStringList.Names[ix][1] = ';') then
        Continue;
      aStrings.Add(CurrStringList.Names[ix]);
    end;
    aStrings.EndUpdate;
  end;
end;

procedure TBigIniFile.ReadSections(aStrings: TStrings);
begin
  aStrings.Assign(FSectionList);
end;

procedure TBigIniFile.ReadSectionValues(const ASection: string; aStrings: TStrings);
var
  SectionIndex: Integer;
begin
  SectionIndex := FSectionList.IndexOf(ASection);
  if SectionIndex <> -1 then
  begin
    aStrings.BeginUpdate;

    if FFlagClearOnReadSectionValues then
      aStrings.Clear;
    aStrings.AddStrings(FSectionList.SectionItems[SectionIndex]);
    aStrings.EndUpdate;
  end;
end;

procedure TBigIniFile.GetStrings(List: TStrings);
var
  ixSections: Integer;
  CurrStringList: TStringList;
begin
  List.BeginUpdate;
  with FSectionList do
  begin
    for ixSections := 0 to Count - 1 do
    begin
      CurrStringList := SectionItems[ixSections];
      if CurrStringList.Count > 0 then
      begin
        List.Add('[' + Strings[ixSections] + ']');
        List.AddStrings(CurrStringList);
        List.Add('');
      end;
    end;
  end;
  List.EndUpdate;
end;

procedure TBigIniFile.SetStrings(const aStrings: TStrings);
var
  CurrStringList: TStringList;
  CurrSectionName: string;
  OneLine: string;
  LL: Integer;
  LastPos, EqPos: Integer;
  nospace: Boolean;
  ix: Integer;
begin
  CurrStringList := nil;
  FPrevSectionIndex := 0;
  for ix := 0 to aStrings.Count - 1 do
  begin
    OneLine := aStrings.Strings[ix];

    if FFlagDropCommentLines then
      if (OneLine <> '') then
        if (OneLine[1] = ';') then
          OneLine := '';

    if OneLine <> '' then
    begin
      LL := Length(OneLine);
      if (OneLine[1] = '[') AND (OneLine[LL] = ']') then
      begin
        CurrSectionName := Copy(OneLine, 2, LL - 2);
        CurrStringList := TStringList.Create;
        FSectionList.AddObject(CurrSectionName, CurrStringList);
      end
      else
      begin
        if FFlagDropWhiteSpace then
        begin
          nospace := False;
          repeat
            EqPos := AnsiPos('=', OneLine);
            if EqPos > 1 then
            begin
              if CharInSet(OneLine[EqPos - 1], [' ', #9]) then
                Delete(OneLine, EqPos - 1, 1)
              else
                nospace := True;
            end
            else
              nospace := True;
          until nospace;
          nospace := False;
          EqPos := AnsiPos('=', OneLine);
          if EqPos > 1 then
          begin
            repeat
              if EqPos < Length(OneLine) then
              begin
                if CharInSet(OneLine[EqPos + 1], [' ', #9]) then
                  Delete(OneLine, EqPos + 1, 1)
                else
                  nospace := True;
              end
              else
                nospace := True;
            until nospace;
          end;
        end;
        if FFlagDropApostrophes then
        begin
          EqPos := AnsiPos('=', OneLine);
          if EqPos > 1 then
          begin
            LL := Length(OneLine);
            if EqPos < LL - 1 then
            begin
              if (OneLine[EqPos + 1] = OneLine[LL]) and CharInSet(OneLine[LL], ['"', #39]) then
              begin
                Delete(OneLine, LL, 1);
                Delete(OneLine, EqPos + 1, 1);
              end;
            end;
          end;
        end;
        if FFlagTrimRight then
        begin
          LastPos := Length(OneLine);
          while ((LastPos > 0) AND (OneLine[LastPos] < #33)) do
            Dec(LastPos);
          OneLine := Copy(OneLine, 1, LastPos);
        end;
        if (NOT FFlagFilterOutInvalid) OR (AnsiPos('=', OneLine) > 0) then
        begin
          if Assigned(CurrStringList) then
            CurrStringList.Add(OneLine);
        end;
      end;
    end;
  end;
  if FSectionList.EraseDuplicates(FEraseSectionCallback) then
    FHasChanged := True;
end;

procedure TBigIniFile.FlushFile;
var
  CurrStringList: TStringList;
  lpTextBuffer: Pointer;
  Destin: TextFile;
  ix, ixSections: Integer;
begin
  lpTextBuffer := nil;
  if FHasChanged then
  begin
    if FFileName <> '' then
    begin
      Assign(Destin, FFileName);
      if FTextBufferSize > 0 then
      begin
        GetMem(lpTextBuffer, FTextBufferSize);
        SetTextBuf(Destin, lpTextBuffer^, FTextBufferSize);
      end;
      Rewrite(Destin);

      with FSectionList do
      begin
        for ixSections := 0 to Count - 1 do
        begin
          CurrStringList := SectionItems[ixSections];
          if CurrStringList.Count > 0 then
          begin
            WriteLn(Destin, '[', Strings[ixSections], ']');
            for ix := 0 to CurrStringList.Count - 1 do
            begin
              WriteLn(Destin, CurrStringList[ix]);
            end;
            WriteLn(Destin);
          end;
        end;
      end;

      Close(Destin);
      if FTextBufferSize > 0 then
      begin
        FreeMem(lpTextBuffer, FTextBufferSize);
      end;
    end;
    FHasChanged := False;
  end;
end;

procedure TBigIniFile.UpdateFile;
begin
  FlushFile;
end;

procedure TBigIniFile.EraseSection(const ASection: string);
var
  SectionIndex: Integer;
begin
  SectionIndex := FSectionList.IndexOf(ASection);
  if SectionIndex <> -1 then
  begin
    FSectionList.SectionItems[SectionIndex].Free;
    FSectionList.Delete(SectionIndex);
    FSectionList.FPrevIndex := 0;
    FHasChanged := True;
    if FPrevSectionIndex >= FSectionList.Count then
      FPrevSectionIndex := 0;
  end;
end;

procedure TBigIniFile.DeleteKey(const ASection, AKey: string);
var
  ItemIndex: Integer;
  CurrStringList: TStringList;
begin
  ItemIndex := FindItemIndex(ASection, AKey, True, CurrStringList);
  if ItemIndex > -1 then
  begin
    FHasChanged := True;
    CurrStringList.Delete(ItemIndex);
  end;
end;

function TBigIniFile.SectionExists(const ASection: string): Boolean;
begin
  Result := FSectionList.IndexOf(ASection) > -1
end;

function TBigIniFile.ValueExists(const ASection, AKey: string): Boolean;
var
  S: TStringList;
begin
  S := TStringList.Create;
  try
    ReadSection(ASection, S);
    Result := S.IndexOf(AKey) > -1;
  finally
    S.Free;
  end;
end;

end.
