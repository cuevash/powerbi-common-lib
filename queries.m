// CL_TrimColumnUpperHeaders
let
    Source = (table) =>  
        let 
            TrimColumns = Table.TransformColumnNames(table, Text.Trim),
            UpperColumns = Table.TransformColumnNames(table, Text.Upper)
        in
            UpperColumns
in
    Source

// CL_YearWeekToDateISO
let
    Source = (year as number, week as number) =>  
    let  
        firstDayYear = #date(year,1,2),
        startOfFirstWeek = Date.StartOfWeek(firstDayYear, Day.Monday),
        startOfWeek = Date.AddWeeks(startOfFirstWeek, week - 1)
    in
        startOfWeek
in
    Source

// CL_TrimColumnHeaders
let
    Source = (table) =>  
        let 
            TrimColumns = Table.TransformColumnNames(table, Text.Trim)
        in
            TrimColumns
in
    Source

// CL_Help
let
    Help = #shared,
    #"Converted to Table" = Record.ToTable(Help)
in
    #"Converted to Table"

// CL_Calendar
let fnDateTable = (StartDate as date, EndDate as date, FYStartMonth as number, CountryLanguage as text, FirstDayOfWeek as number) as table =>
  let
    // Default Country, Language
    countryLang = if CountryLanguage = null then "us-EN"  else CountryLanguage,

    DayCount = Duration.Days(Duration.From(EndDate - StartDate)),
    Source = List.Dates(StartDate,DayCount,#duration(1,0,0,0)),
    TableFromList = Table.FromList(Source, Splitter.SplitByNothing()),   
    ChangedType = Table.TransformColumnTypes(TableFromList,{{"Column1", type date}}, countryLang),
    RenamedColumns = Table.RenameColumns(ChangedType,{{"Column1", "Date"}}),
    InsertYear = Table.AddColumn(RenamedColumns, "Year", each Date.Year([Date]),type text),
    InsertYearNumber = Table.AddColumn(RenamedColumns, "YearNumber", each Date.Year([Date])),
    InsertQuarter = Table.AddColumn(InsertYear, "QuarterOfYear", each Date.QuarterOfYear([Date])),
    InsertMonth = Table.AddColumn(InsertQuarter, "MonthOfYear", each Date.Month([Date]), type text),
    InsertDay = Table.AddColumn(InsertMonth, "DayOfMonth", each Date.Day([Date])),
    InsertDayInt = Table.AddColumn(InsertDay, "DateInt", each [Year] * 10000 + [MonthOfYear] * 100 + [DayOfMonth]),
    InsertMonthName = Table.AddColumn(InsertDayInt, "MonthName", each Date.ToText([Date], "MMMM", countryLang), type text),
    InsertCalendarMonth = Table.AddColumn(InsertMonthName, "MonthInCalendar", each Date.ToText([Date], "MMM yyyy", countryLang), type text),
    InsertCalendarQtr = Table.AddColumn(InsertCalendarMonth, "QuarterInCalendar", each "Q" & Number.ToText([QuarterOfYear]) & " " & Number.ToText([Year]), type text),
    InsertDayWeek = Table.AddColumn(InsertCalendarQtr, "DayInWeek", each Date.DayOfWeek([Date], FirstDayOfWeek)),
    InsertDayName = Table.AddColumn(InsertDayWeek, "DayOfWeekName", each Date.DayOfWeekName([Date], CountryLanguage)),
    InsertWeekEnding = Table.AddColumn(InsertDayName, "WeekEnding", each Date.EndOfWeek([Date], FirstDayOfWeek), type date),
    InsertWeekNumber= Table.AddColumn(InsertWeekEnding, "Week Number", each Date.WeekOfYear([Date], FirstDayOfWeek)),
    InsertMonthnYear = Table.AddColumn(InsertWeekNumber,"MonthnYear", each [Year] * 10000 + [MonthOfYear] * 100),
    InsertQuarternYear = Table.AddColumn(InsertMonthnYear,"QuarternYear", each [Year] * 10000 + [QuarterOfYear] * 100),
    ChangedType1 = Table.TransformColumnTypes(InsertQuarternYear,{{"QuarternYear", Int64.Type},{"Week Number", Int64.Type},{"Year", type text},{"MonthnYear", Int64.Type}, {"DateInt", Int64.Type}, {"DayOfMonth", Int64.Type}, {"MonthOfYear", Int64.Type}, {"QuarterOfYear", Int64.Type}, {"MonthInCalendar", type text}, {"QuarterInCalendar", type text}, {"DayInWeek", Int64.Type}}),
    InsertShortYear = Table.AddColumn(ChangedType1, "ShortYear", each Date.ToText([Date], "yy", countryLang), type text),
    AddFY = Table.AddColumn(InsertShortYear, "FY", each "FY"&(if [MonthOfYear]>=FYStartMonth then Text.From(Number.From([ShortYear])+1) else [ShortYear]))
in
    AddFY
in
    fnDateTable

// CL_Calendar_SP_ES
let fnDateTable = (StartDate as date, EndDate as date) as table =>
  let
    // Based on the standard calendar in english columns
    SourceCalendar_SP_EN = CL_Calendar(StartDate, EndDate, 1, "es-ES", Day.Monday),

    // Renamed Columns to ES
    RenamedColumns = Table.RenameColumns(SourceCalendar_SP_EN,{{"Date", "Fecha"}, {"Year", "Año"}, {"QuarterOfYear", "Trimestre"}, {"MonthOfYear", "MesNum"}, {"DayOfMonth", "DiaDelMes"}, {"DateInt", "FechaInt"}, {"MonthName", "Mes"}, {"MonthInCalendar", "MesCortoAñoFmt"}, {"QuarterInCalendar", "TrimestreAñoFmt"}, {"DayInWeek", "DiaDeLaSemanaNum"}, {"DayOfWeekName", "DiaDeLaSemana"}, {"WeekEnding", "SemanaFin"}, {"Week Number", "SemanaDelAño"}, {"MonthnYear", "AñoMesNth"}, {"QuarternYear", "AñoTrimestreNth"}, {"ShortYear", "AñoCorto"}})
  in
    RenamedColumns
in
  fnDateTable

// CL_Calendar_SP_EN
let fnDateTable = (StartDate as date, EndDate as date) as table =>
  let
    // Based on the standard calendar in english columns
    SourceCalendar_SP_EN = CL_Calendar(StartDate, EndDate, 1, "es-EN", Day.Monday),

    // Renamed Columns to ES
    RenamedColumns = Table.RenameColumns(SourceCalendar_SP_EN,{{"Date", "Fecha"}, {"Year", "Año"}, {"QuarterOfYear", "Trimestre"}, {"MonthOfYear", "MesNum"}, {"DayOfMonth", "DiaDelMes"}, {"DateInt", "FechaInt"}, {"MonthName", "Mes"}, {"MonthInCalendar", "MesCortoAñoFmt"}, {"QuarterInCalendar", "TrimestreAñoFmt"}, {"DayInWeek", "DiaDeLaSemanaNum"}, {"DayOfWeekName", "DiaDeLaSemana"}, {"WeekEnding", "SemanaFin"}, {"Week Number", "SemanaDelAño"}, {"MonthnYear", "AñoMesNth"}, {"QuarternYear", "AñoTrimestreNth"}, {"ShortYear", "AñoCorto"}})
  in
    RenamedColumns
in
  fnDateTable

// CL_Calendar_SP_ES_Ex
let
    Source = CL_Calendar_SP_ES(#date(2020, 4, 4), #date(2021, 4, 4))
in
    Source

// CL_Calendar_SP_EN_Ex
let
    Source = CL_Calendar_SP_EN(#date(2020, 4, 4), #date(2021, 4, 4))
in
    Source

// common-lib-version
let
  Source = #table({"Version"}, {{"1.2"}})
in
  Source

// CL_ISO_3166-2:ES_Autonomous_Communities_And_Cities
let
    Source = Web.Page(Web.Contents("https://en.wikipedia.org/wiki/ISO_3166-2:ES")),
    Data0 = Source{0}[Data],
    #"Changed Type" = Table.TransformColumnTypes(Data0,{{"Code", type text}, {"Subdivision name (es)[note 1]", type text}, {"Subdivision name (en)[note 2]", type text}, {"Subdivision category", type text}}),
    #"Promoted Headers" = Table.PromoteHeaders(#"Changed Type", [PromoteAllScalars=true]),
    #"Changed Type1" = Table.TransformColumnTypes(#"Promoted Headers",{{"Code", type text}, {"Subdivision name (es)", type text}, {"Subdivision name (en)", type text}, {"Subdivision category", type text}}),
    #"Trimmed Text" = Table.TransformColumns(#"Changed Type1",{{"Code", Text.Trim, type text}, {"Subdivision name (es)", Text.Trim, type text}, {"Subdivision name (en)", Text.Trim, type text}, {"Subdivision category", Text.Trim, type text}}),
    #"Renamed Columns" = Table.RenameColumns(#"Trimmed Text",{{"Code", "CodeISO"}}),
    #"Duplicated Column" = Table.DuplicateColumn(#"Renamed Columns", "CodeISO", "CodeISO - Copy"),
    #"Split Column by Delimiter" = Table.SplitColumn(#"Duplicated Column", "CodeISO - Copy", Splitter.SplitTextByEachDelimiter({"-"}, QuoteStyle.Csv, true), {"CodeISO - Copy.1", "CodeISO - Copy.2"}),
    #"Changed Type2" = Table.TransformColumnTypes(#"Split Column by Delimiter",{{"CodeISO - Copy.1", type text}, {"CodeISO - Copy.2", type text}}),
    #"Renamed Columns1" = Table.RenameColumns(#"Changed Type2",{{"CodeISO - Copy.2", "CodeES"}}),
    #"Reordered Columns" = Table.ReorderColumns(#"Renamed Columns1",{"CodeISO", "CodeES", "Subdivision name (es)", "Subdivision name (en)", "Subdivision category", "CodeISO - Copy.1"}),
    #"Removed Columns" = Table.RemoveColumns(#"Reordered Columns",{"CodeISO - Copy.1"}),
    #"Renamed Columns2" = Table.RenameColumns(#"Removed Columns",{{"Subdivision name (es)", "Name_ES"}, {"Subdivision name (en)", "Name_EN"}, {"Subdivision category", "Category"}, {"CodeISO", "ISO_Code"}, {"CodeES", "ES_Code"}})
in
    #"Renamed Columns2"

// CL_ISO_3166-2:ES_Provinces
let
    Source = Web.Page(Web.Contents("https://en.wikipedia.org/wiki/ISO_3166-2:ES")),
    Data1 = Source{1}[Data],
    #"Changed Type" = Table.TransformColumnTypes(Data1,{{"Code", type text}, {"Subdivision name (es)", type text}, {"In autonomous community", type text}}),
    #"Trimmed Text" = Table.TransformColumns(#"Changed Type",{{"Code", Text.Trim, type text}, {"Subdivision name (es)", Text.Trim, type text}, {"In autonomous community", Text.Trim, type text}}),
    #"Renamed Columns" = Table.RenameColumns(#"Trimmed Text",{{"Code", "ISO_Code"}, {"Subdivision name (es)", "Name_ES"}, {"In autonomous community", "Autonomous_Community_Code_ES"}})
in
    #"Renamed Columns"

// CL_ISO_3166-2:ES_Provinces_ES
let
    Source = #"CL_ISO_3166-2:ES_Provinces",
    #"Renamed Columns" = Table.RenameColumns(Source,{{"ISO_Code", "ISO_ID"}, {"Name_ES", "Nombre_ES"}, {"Autonomous_Community_Code_ES", "CCAA_ID_ES"}})
in
    #"Renamed Columns"

// CL_ISO_3166-2:ES_Autonomous_Communities_And_Cities_ES_
let
    Source = #"CL_ISO_3166-2:ES_Autonomous_Communities_And_Cities",
    #"Renamed Columns" = Table.RenameColumns(Source,{{"ISO_Code", "ISO_ID"}, {"ES_Code", "CCAA_ID"}, {"Name_ES", "Nombre_ES"}, {"Name_EN", "Nombre_EN"}, {"Category", "Categoría"}})
in
    #"Renamed Columns"