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