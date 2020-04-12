let

  CL_TrimColumnUpperHeaders = 
  let
      Source = (table) =>  
          let 
              TrimColumns = Table.TransformColumnNames(table, Text.Trim),
              UpperColumns = Table.TransformColumnNames(table, Text.Upper)
          in
              UpperColumns
  in
      Source,

  CL_YearWeekToDateISO =
  let
      Source = (year as number, week as number) =>  
      let  
          firstDayYear = #date(year,1,2),
          startOfFirstWeek = Date.StartOfWeek(firstDayYear, Day.Monday),
          startOfWeek = Date.AddWeeks(startOfFirstWeek, week - 1)
      in
          startOfWeek
  in
      Source,

  CL_TrimColumnHeaders =
  let
      Source = (table) =>  
          let 
              TrimColumns = Table.TransformColumnNames(table, Text.Trim)
          in
              TrimColumns
  in
      Source,

  CL_Table_TrimAndCapitalizeHeaders =
  let
      Source = (table) =>  
          let 
              TrimColumns = Table.TransformColumnNames(table, Text.Trim),
              UpperColumns = Table.TransformColumnNames(table, Text.Proper)
          in
              UpperColumns
  in
      Source,

  CL_Calendar = 
  let fnDateTable = (StartDate as date, EndDate as date, FYStartMonth as number, CountryLanguage as text, FirstDayOfWeek as number) as table =>
    let
      // Default Country, Language
      countryLang = if CountryLanguage = null then "us-EN"  else CountryLanguage,

      DayCount = Duration.Days(Duration.From(EndDate - StartDate)),
      Source = List.Dates(StartDate,DayCount,#duration(1,0,0,0)),
      TableFromList = Table.FromList(Source, Splitter.SplitByNothing()),   
      ChangedType = Table.TransformColumnTypes(TableFromList,{{"Column1", type date}}, countryLang),
      RenamedColumns = Table.RenameColumns(ChangedType,{{"Column1", "Date"}}),
      InsertYear = Table.AddColumn(RenamedColumns, "Year", each Date.Year([Date])),
      InsertQuarter = Table.AddColumn(InsertYear, "QuarterOfYear", each Date.QuarterOfYear([Date])),
      InsertMonth = Table.AddColumn(InsertQuarter, "MonthOfYear", each Date.Month([Date])),
      InsertDay = Table.AddColumn(InsertMonth, "DayOfMonth", each Date.Day([Date])),
      InsertDayInt = Table.AddColumn(InsertDay, "DateInt", each [Year] * 10000 + [MonthOfYear] * 100 + [DayOfMonth]),
      InsertMonthName = Table.AddColumn(InsertDayInt, "MonthName", each Date.ToText([Date], "MMMM", countryLang)),
      InsertCalendarMonth = Table.AddColumn(InsertMonthName, "MonthInCalendar", each Date.ToText([Date], "MMM yyyy", countryLang), type text),
      InsertCalendarQtr = Table.AddColumn(InsertCalendarMonth, "QuarterInCalendar", each "Q" & Number.ToText([QuarterOfYear]) & " " & Number.ToText([Year]), type text),
      InsertDayWeek = Table.AddColumn(InsertCalendarQtr, "DayInWeek", each Date.DayOfWeek([Date], FirstDayOfWeek)),
      InsertDayName = Table.AddColumn(InsertDayWeek, "DayOfWeekName", each Date.DayOfWeekName([Date], CountryLanguage)),
      InsertWeekStart = Table.AddColumn(InsertDayName, "WeekStart", each Date.StartOfWeek([Date], FirstDayOfWeek)),
      InsertWeekEnding = Table.AddColumn(InsertWeekStart, "WeekEnding", each Date.EndOfWeek([Date], FirstDayOfWeek)),
      InsertWeekNumber= Table.AddColumn(InsertWeekEnding, "Week Number", each Date.WeekOfYear([Date], FirstDayOfWeek)),
      InsertMonthnYear = Table.AddColumn(InsertWeekNumber,"MonthnYear", each [Year] * 10000 + [MonthOfYear] * 100),
      InsertQuarternYear = Table.AddColumn(InsertMonthnYear,"QuarternYear", each [Year] * 10000 + [QuarterOfYear] * 100),
    // ChangedType1 = Table.TransformColumnTypes(InsertQuarternYear,{{"QuarternYear", Int64.Type},{"Week Number", Int64.Type},{"Year", type text},{"MonthnYear", Int64.Type}, {"DateInt", Int64.Type}, {"DayOfMonth", Int64.Type}, {"MonthOfYear", Int64.Type}, {"QuarterOfYear", Int64.Type}, {"MonthInCalendar", type text}, {"QuarterInCalendar", type text}, {"DayInWeek", Int64.Type}}),
      InsertShortYear = Table.AddColumn(InsertQuarternYear, "ShortYear", each Date.ToText([Date], "yy", countryLang)),
      AddFY = Table.AddColumn(InsertShortYear, "FY", each "FY"&(if [MonthOfYear]>=FYStartMonth then Text.From(Number.From([ShortYear])+1) else [ShortYear])),
      Result = Table.TransformColumnTypes(AddFY,{{"Year", Int64.Type}, {"QuarterOfYear", Int64.Type}, {"MonthOfYear", Int64.Type}, {"DayOfMonth", Int64.Type}, {"DateInt", Int64.Type}, {"MonthName", type text}, {"MonthInCalendar", type text}, {"QuarterInCalendar", type text}, {"DayInWeek", Int64.Type}, {"DayOfWeekName", type text}, {"Week Number", Int64.Type}, {"MonthnYear", Int64.Type}, {"QuarternYear", Int64.Type}, {"ShortYear", Int64.Type}, {"FY", type text}})
  in
      Result
  in
      fnDateTable,

  CL_Calendar_SP_ES = 
  let fnDateTable = (StartDate as date, EndDate as date) as table =>
    let
      // Based on the standard calendar in english columns
      SourceCalendar_SP_EN = CL_Calendar(StartDate, EndDate, 1, "es-ES", Day.Monday),

      // Renamed Columns to ES
      RenamedColumns = Table.RenameColumns(SourceCalendar_SP_EN,{{"Date", "Fecha"}, {"Year", "Año"}, {"QuarterOfYear", "Trimestre"}, {"MonthOfYear", "MesNum"}, {"DayOfMonth", "DiaDelMes"}, {"DateInt", "FechaInt"}, {"MonthName", "Mes"}, {"MonthInCalendar", "MesCortoAñoFmt"}, {"QuarterInCalendar", "TrimestreAñoFmt"}, {"DayInWeek", "DiaDeLaSemanaNum"}, {"DayOfWeekName", "DiaDeLaSemana"},  {"WeekStart", "SemanaInicio"}, {"WeekEnding", "SemanaFin"}, {"Week Number", "SemanaDelAño"}, {"MonthnYear", "AñoMesNth"}, {"QuarternYear", "AñoTrimestreNth"}, {"ShortYear", "AñoCorto"}})
    in
      RenamedColumns
  in
    fnDateTable,

  CL_Calendar_SP_EN =
  let fnDateTable = (StartDate as date, EndDate as date) as table =>
    let
      // Based on the standard calendar in english columns
      SourceCalendar_SP_EN = CL_Calendar(StartDate, EndDate, 1, "es-EN", Day.Monday)
    in
      SourceCalendar_SP_EN
  in
    fnDateTable,

  CL_Calendar_SP_ES_Ex =
  let
      Source = CL_Calendar_SP_ES(#date(2020, 4, 4), #date(2021, 4, 4))
  in
      Source,

  CL_Calendar_SP_EN_Ex =
  let
      Source = CL_Calendar_SP_EN(#date(2020, 4, 4), #date(2021, 4, 4))
  in
      Source,

  CL_ZipFile_Document =
  (ZIPFile) => 
  let
      Header = BinaryFormat.Record([
          MiscHeader = BinaryFormat.Binary(14),
          BinarySize = BinaryFormat.ByteOrder(BinaryFormat.UnsignedInteger32, ByteOrder.LittleEndian),
          FileSize   = BinaryFormat.ByteOrder(BinaryFormat.UnsignedInteger32, ByteOrder.LittleEndian),
          FileNameLen= BinaryFormat.ByteOrder(BinaryFormat.UnsignedInteger16, ByteOrder.LittleEndian),
          ExtrasLen  = BinaryFormat.ByteOrder(BinaryFormat.UnsignedInteger16, ByteOrder.LittleEndian)    
      ]),

      HeaderChoice = BinaryFormat.Choice(
          BinaryFormat.ByteOrder(BinaryFormat.UnsignedInteger32, ByteOrder.LittleEndian),
          each if _ <> 67324752             // not the IsValid number? then return a dummy formatter
              then BinaryFormat.Record([IsValid = false, Filename=null, Content=null])
              else BinaryFormat.Choice(
                      BinaryFormat.Binary(26),      // Header payload - 14+4+4+2+2
                      each BinaryFormat.Record([
                          IsValid  = true,
                          Filename = BinaryFormat.Text(Header(_)[FileNameLen]), 
                          Extras   = BinaryFormat.Text(Header(_)[ExtrasLen]), 
                          Content  = BinaryFormat.Transform(
                              BinaryFormat.Binary(Header(_)[BinarySize]),
                              (x) => try Binary.Buffer(Binary.Decompress(x, Compression.Deflate)) otherwise null
                          )
                          ]),
                          type binary                   // enable streaming
                  )
      ),

      ZipFormat = BinaryFormat.List(HeaderChoice, each _[IsValid] = true),

      Entries = List.Transform(
          List.RemoveLastN( ZipFormat(ZIPFile), 1),
          (e) => [FileName = e[Filename], Content = e[Content] ]
      )
  in
      Table.FromRecords(Entries),

  CL_Table_RemoveColumnsWithBlankHeader =
  let
      Source = (tbl as table) =>
  let
      Headers = Table.ColumnNames(tbl),

      Result = Table.SelectColumns(
                  tbl,
                  List.Select(Headers, each List.MatchesAny(Table.Column(tbl, _), each  (_ <> null) and (_ <> ""))  ))
  in
      Result
  in
      Source,

  CL_WorldBankIndicatorsLang =
  "en" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true],

  CL_WorldBankIndicators =
  "AG.AGR.TRAC.NO;SP.POP.TOTL" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true],

  #"CL WorldBank Sample" =
  let
          Source = Web.Contents("http://api.worldbank.org/v2/", [RelativePath= CL_WorldBankIndicatorsLang & "/country/ind/indicator/" & CL_WorldBankIndicators & "?source=2&downloadformat=csv"]),
          Custom1 = CL_ZipFile_Document(Source),
          #"Filtered Rows" = Table.SelectRows(Custom1, each Text.StartsWith([FileName], "API")),
          FileName2 = #"Filtered Rows"{0}[Content],
          #"Imported CSV" = Csv.Document(FileName2,[Delimiter=",", Columns=65, Encoding=65001, QuoteStyle=QuoteStyle.None]),
          #"Promoted Headers" = Table.PromoteHeaders(#"Imported CSV", [PromoteAllScalars=true]),
          Custom2 = Table.Skip(#"Promoted Headers", List.PositionOf(Table.Column(#"Promoted Headers", "Data Source"), "Country Name")),
          #"Promoted Headers2" = Table.PromoteHeaders(Custom2, [PromoteAllScalars=true]),
          Custom3 = CL_Table_TrimAndCapitalizeHeaders(#"Promoted Headers2"),
          Custom4 = CL_Table_RemoveColumnsWithBlankHeader(Custom3),
          #"Unpivoted Other Columns" = Table.UnpivotOtherColumns(Custom4, {"Country Name", "Country Code", "Indicator Name", "Indicator Code"}, "Year", "Value"),
          #"Merged Columns" = Table.CombineColumns(#"Unpivoted Other Columns",{"Indicator Code", "Indicator Name"},Combiner.CombineTextByDelimiter(" - ", QuoteStyle.None),"Indicator"),
      #"Changed Type1" = Table.TransformColumnTypes(#"Merged Columns",{{"Year", Int64.Type}, {"Value", type number}}),
          #"Pivoted Column" = Table.Pivot(#"Changed Type1", List.Distinct(#"Changed Type1"[Indicator]), "Indicator", "Value"),
      #"Changed Type" = Table.TransformColumnTypes(#"Pivoted Column",{{"Year", Int64.Type}})
  in
      #"Changed Type",

  CL_WorldBankAllCountriesIndicators =
  let
      Source = (CL_WorldBankIndicators as text, optional CL_WorldBankIndicatorsLang as text) => let
          Lang = if (CL_WorldBankIndicatorsLang = null) then "" else CL_WorldBankIndicatorsLang,
          Source = Web.Contents("http://api.worldbank.org/v2/", [RelativePath= Lang & "/country/ind/indicator/" & CL_WorldBankIndicators & "?source=2&downloadformat=csv"]),
          Custom1 = CL_ZipFile_Document(Source),
          #"Filtered Rows" = Table.SelectRows(Custom1, each Text.StartsWith([FileName], "API")),
          FileName2 = #"Filtered Rows"{0}[Content],
          #"Imported CSV" = Csv.Document(FileName2,[Delimiter=",", Columns=65, Encoding=65001, QuoteStyle=QuoteStyle.None]),
          #"Promoted Headers" = Table.PromoteHeaders(#"Imported CSV", [PromoteAllScalars=true]),
          Custom2 = Table.Skip(#"Promoted Headers", List.PositionOf(Table.Column(#"Promoted Headers", "Data Source"), "Country Name")),
          #"Promoted Headers2" = Table.PromoteHeaders(Custom2, [PromoteAllScalars=true]),
          Custom3 = CL_Table_TrimAndCapitalizeHeaders(#"Promoted Headers2"),
          Custom4 = CL_Table_RemoveColumnsWithBlankHeader(Custom3),
          #"Unpivoted Other Columns" = Table.UnpivotOtherColumns(Custom4, {"Country Name", "Country Code", "Indicator Name", "Indicator Code"}, "Year", "Value"),
          #"Merged Columns" = Table.CombineColumns(#"Unpivoted Other Columns",{"Indicator Code", "Indicator Name"},Combiner.CombineTextByDelimiter(" - ", QuoteStyle.None),"Indicator"),
      #"Changed Type1" = Table.TransformColumnTypes(#"Merged Columns",{{"Year", Int64.Type}, {"Value", type number}}),
          #"Pivoted Column" = Table.Pivot(#"Changed Type1", List.Distinct(#"Changed Type1"[Indicator]), "Indicator", "Value"),
      #"Changed Type" = Table.TransformColumnTypes(#"Pivoted Column",{{"Year", Int64.Type}})
  in
      #"Changed Type"
  in
      Source,

  Version_History =
  let
      //Source = Table.FromRows(Json.Document(Binary.Decompress(Binary.FromText("i45WMtQz0jNU0lEyMjAy0Dcw0TcEcTJSk0vyixyKM/PSS3MSi9ISk0v0kvNzgTLKCn75JanFMXkxeU45iQpJEAziKisruKUmlpQWQWR1FfzzUkFUSHk+mMooSk1Vio0FAA==", BinaryEncoding.Base64), Compression.Deflate)), let _t = ((type text) meta [Serialized.Text = true]) in type table [Version = _t, #"Revision Date/Time" = _t, #"Developer Name" = _t, #"Revision Notes (md)" = _t]),
      Table0 = Table.FromRecords(
        {[ 
          Version = "1.2.1", 
          Revision Date_Time = "2020/04/11",
          Developer Name = "hector@singularfact.com",
          Revision Notes md = "
# Notes

Bla bla bla

## Features

- One
- Two
- Three
          "
        ]}, 
        type table[
          Version = Text.Type,
          Revision Date_Time = Text.Type,
          Developer Name = Text.Type,
          Revision Notes md = Text.Type
        ]),

    // Here is where the version are added.
      TableNewRows =  Table.InsertRows(Table0 , 1, 
      {
        [ 
          Version = "1.3", 
          Revision Date_Time = "2020/04/12",
          Developer Name = "hector@singularfact.com",
          Revision Notes md = "
# Notes

## Features

- Lib is now converted to a list that can be Versioned Controlled into GitHub

          "]
      }),

      
      TableRenameColumns = Table.RenameColumns(TableNewRows,{{"Revision Date_Time", "Revision Date/Time"}, {"Revision Notes md", "Revision Notes (md)"}}),
      #"Changed Type1" = Table.TransformColumnTypes(TableRenameColumns,{{"Revision Date/Time", type datetime}}),
      #"Added Custom" = Table.AddColumn(#"Changed Type1", "Refresh Date/Time", each DateTime.LocalNow()),
      #"Changed Type" = Table.TransformColumnTypes(#"Added Custom",{{"Refresh Date/Time", type datetimezone}})
  in
     #"Changed Type",

  // Build LIB
  CL_Lib = [
    Version_History = Version_History,
    CL_TrimColumnUpperHeaders = CL_TrimColumnUpperHeaders,
    CL_YearWeekToDateISO = CL_YearWeekToDateISO,
    CL_TrimColumnHeaders = CL_TrimColumnHeaders,
    CL_Table_TrimAndCapitalizeHeaders = CL_Table_TrimAndCapitalizeHeaders,
    CL_Calendar = CL_Calendar,
    CL_Calendar_SP_ES = CL_Calendar_SP_ES,
    CL_Calendar_SP_EN = CL_Calendar_SP_EN,
    CL_Calendar_SP_ES_Ex = CL_Calendar_SP_ES_Ex,
    CL_Calendar_SP_EN_Ex = CL_Calendar_SP_EN_Ex,
    CL_ZipFile_Document = CL_ZipFile_Document,
    CL_Table_RemoveColumnsWithBlankHeader = CL_Table_RemoveColumnsWithBlankHeader,
    CL_WorldBankIndicatorsLang = CL_WorldBankIndicatorsLang,
    CL_WorldBankIndicators = CL_WorldBankIndicators,
    CL WorldBank Sample = #"CL WorldBank Sample",
    CL_WorldBankAllCountriesIndicators = CL_WorldBankAllCountriesIndicators
  ]
in
  CL_Lib
