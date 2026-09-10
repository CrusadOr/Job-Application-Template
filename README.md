# LaTeX CV

This project separates CV data from presentation and includes a privacy-safe,
fictional example:

- `CV.tex` contains fictional example information expressed through semantic
  commands.
- `CV.cls` validates that information and controls all formatting.
- `CV.pdf` is the rendered fictional example.
- `MyCVs/` is a Git-ignored local directory for private and tailored CVs.

## Build

Open the `.tex` file that you want to build, then run the LaTeX Workshop build
command (`Ctrl+Alt+B`). The output location follows the source location:

| Source | Final PDF |
| --- | --- |
| `CV.tex` | `CV.pdf` |
| `MyCVs/General.tex` | `MyCVs/CV.pdf` |
| `MyCVs/Tailored-Role.tex` | `MyCVs/CV.pdf` (replaces the preceding private build) |

Each source has a separate auxiliary directory under `.cv-build/`, so
switching among tailored CVs does not reuse another source's build state. The
selected source is rebuilt once even when it has not changed, ensuring that it
always replaces the shared `MyCVs/CV.pdf`.

From a terminal opened in the project root, run either:

```powershell
latexmk CV.tex
latexmk MyCVs/Tailored-Role.tex
```

Both methods use `.latexmkrc`. Every finished document is named `CV.pdf`; a
private build therefore replaces only `MyCVs/CV.pdf`, never the public example.

### Private CVs and public repositories

The entire `MyCVs/` directory is ignored by Git. It may contain any number of
independent `.tex` sources, a private photo, and the most recently rendered
private `CV.pdf`. For example:

```text
MyCVs/
|-- General.tex
|-- Embedded-Engineer.tex
|-- FPGA-Engineer.tex
|-- photo.png
`-- CV.pdf
```

Builds run from the project root so that every private source can find
`CV.cls`. Paths to private assets are therefore workspace-relative; for
example, use `\photo{MyCVs/photo.png}{0.20\linewidth}`.

When creating a public repository, copy only the public tracked files. Do not
copy `MyCVs/`, `.cv-build/`, `.latex-build/`, or the existing `.git/`
directory. Git ignore rules protect new commits, but they cannot remove private
information from an existing repository's history.

## General usage rules

All CV declarations must appear before `\begin{document}`. The document body is
intentionally empty because `CV.cls` renders the collected information when the
document begins.

```latex
\documentclass{CV}

% CV declarations go here.

\begin{document}
\end{document}
```

Additional rules:

- Entries and repeated values appear in the order in which they are declared.
- Structured commands such as `\education` use comma-separated `key = {value}`
  arguments.
- Required keys must contain a non-empty value. Missing required keys cause a
  `CV` class error during the build.
- Optional keys may be omitted entirely.
- Commands such as `\educationskill`, `\course`, and `\projectdetail` are child commands. Use them
  only inside the indicated parent key.
- Descriptions and evidence may wrap naturally across multiple rendered lines.
- In entries with an institution, company, or other organisation, its name is
  displayed beneath the entry title on the left, with a small gap before the
  description.
- Values are ordinary LaTeX text. Escape reserved LaTeX characters when they
  are meant literally, for example `\&`, `\%`, `\_`, `\#`, and `\$`.

## Inline webpage links

### `\weblink{label}{URL}`

Adds a clickable webpage link inside another command's text. Use it, for
example, to link a course certificate, project page, implementation, or source
repository. The label is displayed in the CV's link colour; the URL itself is
not printed.

| Argument | Required | Description |
| --- | --- | --- |
| `label` | Yes | Text displayed in the PDF, such as `View certificate` or `Project repository`. |
| `URL` | Yes | Complete destination URL, including `https://`. |

Unlike a top-level declaration, `\weblink` is embedded wherever linked text is
needed:

```latex
\course{Digital Signal Processing}{Completed practical filter-design work. \weblink{View certificate}{https://example.com/certificate}}

\projectdetail{Implemented the application in Python. \weblink{View implementation}{https://github.com/example/project}}
```

## Header and profile commands

### `\name{full name}`

Sets the name displayed at the top of the CV and used as the PDF author.

|   Argument  | Required |                               Description                                    |
|-------------|----------|------------------------------------------------------------------------------|
| `full name` |    Yes   | The candidate's full name. This is the only required top-level header field. |

Calling `\name` again replaces the previous name.

### `\headline{text}`

Sets the short line below the name, such as a current role or professional
identity.

| Argument | Required | Description |
| --- | --- | --- |
| `text` | Yes | Free text, for example `Incoming Master's student`. |

The command itself is optional. Calling it again replaces the previous
headline.

### `\phone{number}`

Adds a phone number to the contact line.

| Argument | Required | Description |
| --- | --- | --- |
| `number` | Yes | The displayed number, preferably including the country code. |

The command is optional and repeatable.

### `\address{location}`

Adds an address or location to the contact line.

| Argument | Required | Description |
| --- | --- | --- |
| `location` | Yes | Free text such as `Example City`. |

The command is optional and repeatable.

### `\email{address}`

Adds a clickable email address to the contact line.

| Argument | Required | Description |
| --- | --- | --- |
| `address` | Yes | The displayed email address and `mailto:` destination. |

The command is optional and repeatable.

### `\profilelink{label}{URL}`

Adds a clickable external profile to the contact line.

| Argument | Required | Description |
| --- | --- | --- |
| `label` | Yes | Short displayed text, such as `LinkedIn` or `GitHub`. |
| `URL` | Yes | The complete destination URL, including `https://`. |

The command is optional and repeatable.

### `\profile{text}`

Sets the paragraph displayed in the **Profile** section.

| Argument | Required | Description |
| --- | --- | --- |
| `text` | Yes | A concise professional summary. |

The command itself is optional. If it is omitted, the Profile section is not
rendered. Calling it again replaces the previous profile. When both profile and
skills are present, Profile is rendered on the left and **Hard Skills & Tools** on the right;
Education begins below the shared top block.

### `\photo{path}{width}`

Adds an optional photo to the right of the **Hard Skills & Tools** section. When
used together with Profile and Hard Skills & Tools, the three elements share one
top row; Education begins below them. The class measures Profile and Hard Skills
& Tools and automatically divides the remaining width between them so their
rendered heights are as close as possible. When the photo is omitted, Profile
and Hard Skills & Tools retain a balanced two-column layout and no empty photo
column is reserved.

| Argument | Required | Description |
| --- | --- | --- |
| `path` | Yes | Path to a PNG, JPEG, or PDF image, relative to `CV.tex` unless an absolute path is supplied. Include the file extension. |
| `width` | Yes | Display width as a LaTeX dimension, such as `3cm`, or as a fraction of the available line width, such as `0.20\linewidth`. It must be positive and smaller than `0.30\linewidth`. |

```latex
\photo{images/profile-photo.jpg}{0.20\linewidth}
```

The command itself is optional. Calling it again replaces the previous photo
and width. The image keeps its aspect ratio.
The referenced image should be included in source control when it is required
to build the CV.

## Education

### `\education{key-value list}`

Adds one entry to the **Education** section.

| Key | Required | Possible values and effect |
| --- | --- | --- |
| `institution` | Yes | Institution name, displayed beneath the programme title. |
| `institution-url` | No | Complete URL. When present, the institution name becomes a link. |
| `program` | Yes | Degree or programme name. |
| `start` | Yes | Free-text start date, such as `2022` or `October 2026`. |
| `end` | Conditionally | Free-text graduation date, such as `2026` or `June 2028`. Required for `completed` and `expected`; unnecessary for `absent`. |
| `end-status` | No | `completed` (default) prints `end` unchanged; `expected` appends `(expected)`; `absent` prints only the start date. No other values are accepted. |
| `grade` | No | Average grade or another concise result. It is displayed as `Grade: ...` beneath the date on the right. |
| `description` | Yes | Brief description of the programme. |
| `skills` | No | Zero or more `\educationskill{name}{description}` declarations, rendered with dash markers after the courses. |
| `courses` | No | Zero or more `\course{name}{description}` declarations, rendered with bullet markers before the education skills. No heading is added above the list. |

```latex
\education{
  institution = {Example University},
  institution-url = {https://example.edu/},
  program = {M.Sc. Example Engineering},
  start = {October 2026},
  end = {2028},
  end-status = {expected},
  grade = {B},
  description = {Brief description of the programme.},
  courses = {
    \course{Digital Signal Processing}{Analysed and implemented digital filters.}
    \course{Embedded Systems}{Developed software for resource-constrained hardware.}
  },
  skills = {
    \educationskill{Mathematics}{Applied advanced mathematical methods.}
    \educationskill{Physics}{Completed theoretical and experimental coursework.}
  }
}
```

To display only an education start date, omit `end` and explicitly set:

```latex
start = {October 2026},
end-status = {absent},
```

### `\educationskill{name}{description}`

Adds one skill bullet inside the optional `skills` key of an `\education` entry.

| Argument | Required | Description |
| --- | --- | --- |
| `name` | Yes | Concise skill or subject name. |
| `description` | Yes | Explanation of how the skill was acquired or demonstrated. |

The command may be repeated any number of times. Do not use it at the top level.

### `\course{name}{description}`

Adds one course bullet inside the `courses` key of an `\education` entry. The
course name is rendered in bold, followed by its description.

| Argument | Required | Description |
| --- | --- | --- |
| `name` | Yes | Course name. |
| `description` | Yes | Explanation of the course content, work, or acquired knowledge. |

The command may be repeated any number of times. Do not use it at the top level.

## Work experience

### `\experience{key-value list}`

Adds one entry to the **Work Experience** section.

| Key | Required | Possible values and effect |
| --- | --- | --- |
| `company` | No | Company or organisation name, displayed beneath the position title. When omitted, no empty company row is rendered. |
| `company-url` | No | Complete URL. When both it and `company` are present, the company name becomes a link. It has no visible effect without `company`. |
| `position` | Yes | Position or role name. |
| `context` | No | Team, department, laboratory, or course. It is displayed after the position. |
| `start` | Yes | Free-text start date. |
| `end` | Conditionally | Required for `completed` and `expected`; unnecessary for `ongoing` and `absent`. |
| `end-status` | No | `completed` (default) prints `end`; `expected` prints `end (expected)`; `ongoing` prints `Present`; `absent` prints only the start date. No other values are accepted. |
| `description` | Yes | Brief description of the role and its scope. |
| `skills` | Yes | One or more `\experienceskill{name}{description}` declarations. |

```latex
\experience{
  company = {Example Company},
  company-url = {https://example.com/},
  position = {Engineering Intern},
  context = {Embedded Systems Laboratory},
  start = {March 2026},
  end-status = {ongoing},
  description = {Worked on embedded signal-processing systems.},
  skills = {
    \experienceskill{FPGA development}{Implemented and tested FPGA modules.}
    \experienceskill{Teamwork}{Collaborated with hardware and software engineers.}
  }
}
```

To display only a start date, omit `end` and explicitly set:

```latex
start = {March 2026},
end-status = {absent},
```

### `\experienceskill{name}{description}`

Adds one skill bullet inside the `skills` key of an `\experience` entry.

| Argument | Required | Description |
| --- | --- | --- |
| `name` | Yes | Concise skill or responsibility name. |
| `description` | Yes | Short explanation of how the skill was used or demonstrated. |

The command may be repeated. Do not use it at the top level.

## Projects

### `\project{key-value list}`

Adds one entry to the **Projects** section.

| Key | Required | Possible values and effect |
| --- | --- | --- |
| `name` | Yes | Project name. |
| `organisation` | No | Company, university, or other organisation associated with the project. It is displayed beneath the project name. When omitted, no empty organisation row is rendered. |
| `organisation-url` | No | Complete URL. When both it and `organisation` are present, the organisation name becomes a link. It has no visible effect without `organisation`. |
| `date` | Yes | Free-text date: a year, month and year, or date range. |
| `description` | Yes | Brief project context or summary. |
| `items` | Yes | One or more `\projectdetail` or `\projectmetric` declarations. They may be declared in any order; metrics are rendered first as bullets, followed by details marked with dashes. |

```latex
\project{
  name = {Example FPGA Project},
  organisation = {Example University},
  organisation-url = {https://example.edu/},
  date = {January 2026 – May 2026},
  description = {University laboratory project.},
  items = {
    \projectdetail{Implemented the design in VHDL.}
    \projectmetric{Clock frequency}{100 MHz}{Met the target timing constraint.}
  }
}
```

### `\projectdetail{description}`

Adds a dashed description item inside a project's `items` key. All project
details are rendered after the project's metrics.

| Argument | Required | Description |
| --- | --- | --- |
| `description` | Yes | One project action, result, technology, or other relevant detail. |

### `\projectmetric{label}{value}{description}`

Adds a metric bullet inside a project's `items` key. All metrics are rendered
before the dashed project details, even if the declarations are interleaved.

| Argument | Required | Description |
| --- | --- | --- |
| `label` | Yes | Metric name, such as `Clock frequency` or `Design width`. |
| `value` | Yes | Measured or defined value, including its unit when applicable. |
| `description` | No (empty braces allowed) | Brief explanation of the metric's meaning or relevance. The third argument must still be written as `{}` when empty; in that case, no dash is printed after the value. |

Both project child commands may be repeated. Do not use them at the top level.

## Hard Skills & Tools

### `\skill{name}`

Adds one skill name to the **Hard Skills & Tools** section. Each skill is
rendered as a compact rounded rectangular box. When a profile is present, the section
is placed to its right and Education starts beneath both sections.

| Argument | Required | Description |
| --- | --- | --- |
| `name` | Yes | Skill, technology, tool, or knowledge area displayed inside the box. |

```latex
\skill{FPGA and SoC Design}
\skill{VHDL}
\skill{MATLAB}
```

The command is optional and repeatable. Skill categories, organisations,
projects, and justifications are not part of this command.

## Additional information

### `\spokenlanguage{key-value list}`

Adds one language to the **Languages** line in the **Additional Information**
section. All declared languages are rendered on that single line, separated by
semicolons; no bullets or nested list markers are used. The `Languages:` label
is bold, while each language name appears in the same rounded box style used by
the Hard Skills & Tools section. Proficiency text remains outside the box.

| Key | Required | Possible values and effect |
| --- | --- | --- |
| `name` | Yes | Language name. |
| `level` | Yes | Free-text proficiency description, such as `Basic knowledge`, `B2`, or `Native`. |

```latex
\spokenlanguage{
  name = {English},
  level = {Full Professional Proficiency}
}
```

The command is repeatable. The other Additional Information values are also
rendered as plain labeled lines without bullets. If no additional-information
commands are used, the entire section is omitted.

### `\careerinterest{text}`

Sets the **Career interests** item in the Additional Information section.

| Argument | Required | Description |
| --- | --- | --- |
| `text` | Yes | Free-text list or statement of professional interests. |

The command itself is optional. Calling it again replaces the previous value.

### `\personalquality{text}`

Adds one value to the **Personal qualities** item.

| Argument | Required | Description |
| --- | --- | --- |
| `text` | Yes | One personal quality or short supporting phrase. |

The command is optional and repeatable.

### `\interest{text}`

Adds one value to the **Interests** item.

| Argument | Required | Description |
| --- | --- | --- |
| `text` | Yes | One interest or hobby. |

The command is optional and repeatable.

## Achievements

### `\achievement{key-value list}`

Adds one entry to the **Other Achievements** section.

| Key | Required | Possible values and effect |
| --- | --- | --- |
| `title` | Yes | Achievement or award title. |
| `organisation` | No | Awarding organisation or event, displayed beneath the achievement title. When omitted, the empty organisation row is not rendered. |
| `organisation-url` | No | Complete URL. When both it and `organisation` are present, the organisation name becomes a link. It has no visible effect without `organisation`. |
| `date` | Yes | Free-text date or date range. |
| `description` | No | Brief explanation of the achievement. |
| `details` | No | Zero or more `\achievementdetail{description}[date]` declarations. |

```latex
\achievement{
  title = {Example Engineering Award},
  organisation = {Example Foundation},
  organisation-url = {https://example.org/},
  date = {2026},
  description = {Awarded for an embedded-systems project.},
  details = {
    \achievementdetail{Selected from 50 submissions.}[2025]
    \achievementdetail{Presented the project at the annual conference.}[2026]
  }
}
```

### `\achievementdetail{description}[date]`

Adds one bullet inside an achievement's `details` key. When supplied, the
detail's own date is displayed on the right side of the bullet.

| Argument | Required | Description |
| --- | --- | --- |
| `description` | Yes | One supporting fact or result. |
| `date` | No | Optional free-text date or date range for this specific detail. |

The command is repeatable. Do not use it at the top level.

## Command summary

| Command | Purpose | Repeatable? |
| --- | --- | --- |
| `\name{...}` | Candidate name | No; a later call replaces the value |
| `\headline{...}` | Header subtitle | No; a later call replaces the value |
| `\phone{...}` | Phone contact | Yes |
| `\address{...}` | Location or address contact | Yes |
| `\email{...}` | Clickable email contact | Yes |
| `\profilelink{...}{...}` | Clickable external profile | Yes |
| `\weblink{...}{...}` | Inline link to a certificate, project, or other webpage | Yes, inside text arguments |
| `\profile{...}` | Profile section | No; a later call replaces the value |
| `\photo{...}{...}` | Optional photo and display width to the right of Hard Skills & Tools | No; a later call replaces both values |
| `\education{...}` | Education entry | Yes |
| `\educationskill{...}{...}` | Skill inside education | Yes, inside `skills` |
| `\course{...}{...}` | Course inside education | Yes, inside `courses` |
| `\experience{...}` | Work-experience entry | Yes |
| `\experienceskill{...}{...}` | Skill inside work experience | Yes, inside `skills` |
| `\project{...}` | Project entry | Yes |
| `\projectdetail{...}` | Project detail | Yes, inside `items` |
| `\projectmetric{...}{...}{...}` | Project metric | Yes, inside `items` |
| `\skill{...}` | Rounded skill-name box beside Profile | Yes |
| `\spokenlanguage{...}` | Spoken language and proficiency | Yes |
| `\careerinterest{...}` | Career interests | No; a later call replaces the value |
| `\personalquality{...}` | Personal quality | Yes |
| `\interest{...}` | Personal interest | Yes |
| `\achievement{...}` | Achievement entry | Yes |
| `\achievementdetail{...}[...]` | Supporting achievement detail with an optional date | Yes, inside `details` |
