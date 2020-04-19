# CONVENTIONS

This document defines some conventions|agreements on several levels of importance.

- **must**: for things we have to do always.
- **should**: for things we should do but it's not a blocker.
- **could**: for nice-to-have things we can do to help each other.

## Table of Contents

- [CONVENTIONS](#conventions)
  - [Table of Contents](#table-of-contents)
  - [Naming](#naming)
    - [Options](#options)
      - [Sentence Case](#sentence-case)
      - [UpperCamel (Pascal Case)](#uppercamel-pascal-case)
      - [Camel Case](#camel-case)
      - [Title Case (Upstyle)](#title-case-upstyle)
      - [Company Short Name](#company-short-name)
    - [[MUST]: Project Language](#must-project-language)
    - [Workspaces](#workspaces)
    - [Datasets](#datasets)
    - [Dataflows](#dataflows)
  - [Power Query (M Language) / PowerBI elements](#power-query-m-language--powerbi-elements)
    - [Groups](#groups)
    - [Tables](#tables)
    - [Columns](#columns)
    - [Function Names](#function-names)
    - [Parameters in a function](#parameters-in-a-function)
    - [Measures](#measures)

## Naming

### Options

#### Sentence Case

- Capitalizing the first letter of the first word in a heading – like you would in a sentence. Proper nouns are also capitalized.

ex: **The Anchor Board Is Gone**

#### UpperCamel (Pascal Case)

- Writing phrases such that each word or abbreviation in the middle of the phrase begins with a capital letter, with no intervening spaces or punctuation. And the first letter is in capital letter

ex: **TheAnchorBoardIsGone**

#### Camel Case

- Writing phrases such that each word or abbreviation in the middle of the phrase begins with a capital letter, with no intervening spaces or punctuation. And the first letter is in lowercase

ex: **theAnchorBoardIsGone**

#### Title Case (Upstyle)

- Capitalizing the first letter of each word:

ex: **This is Title Case.**

#### Company Short Name

- Company's short name, no spaces, {-} allow to connect words:

ex:

- **Toyota**
- **The-One-And-Only**

### [MUST]: Project Language

Code, comments and documentation must be in English language.

---

### Workspaces

[**Company Short Name**] - [Project name in **Sentence Case**]

Project name in english/spanish as covenience demands

ex:

- **Santander - TPV**
- **Toyota - Mercados Emergentes** or **Toyota - Emergent Markets**
- **Bilayer - COVID-19 Evolution**

---

### Datasets

[**Company Short Name**]-[Project name in **Sentence Case**]-["Dataset"].[v.{number}.{number}]

Project name in english/spanish as covenience demands

ex:

- **Santander-TPV-Dataset.v.1.0**
- **Toyota-Mercados-Emergentes-Dataset.v.1.1** or **Toyota-Emergent-Markets-Dataset.v.1.1**
- **Bilayer-COVID-19-Evolution-Dataset.v.1.3**

### Dataflows

---

## Power Query (M Language) / PowerBI elements

### Groups

[**Sentence Case** in english]

ex:

- **Santander-TPV-Dataset.v.1.0**
- **Toyota-Mercados-Emergentes-Dataset.v.1.1** or **Toyota-Emergent-Markets-Dataset.v.1.1**
- **Bilayer-COVID-19-Evolution-Dataset.v.1.3**

### Tables

[**Sentence Case** in english]

All tables in english, and then a final table with translation names to the customer's language used.

ex: We have a _Customer_ table that we use for are references, filters, etc. And then we have a _Cliente_ table that references the _Customer_ table and the only thing it does is to change the names of the columns.

ex:

- **Customer**
- **Sales Territory**

And then if for a spanish audience oriented they maybe converted to:

- **Cliente**
- **Ventas Territorio**

### Columns

[**Sentence Case** in english]

All Columns in english, and then a final table with translation names to the customer's language used.

ex:

- **Confirmed Cases**

And then if for a spanish audience oriented they maybe converted to:

- **Casos Confirmados**

### Function Names

[**UpperCamel**]

ex:

- **Date.IsInPreviousNWeeks(dateTime as any, weeks as number)**

### Parameters in a function

[**Camel Case**]

ex:

- **Date.IsInPreviousNWeeks(dateTime as any, weeks as number)**

### Measures

[**Sentence Case** in customer's language preference]

ex:
