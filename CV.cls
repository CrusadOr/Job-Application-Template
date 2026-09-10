%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (C) 2010 by Trey Hunner
%
% Copying and distribution of this file, with or without modification,
% are permitted in any medium without royalty provided the copyright
% notice and this notice are preserved. This file is offered as-is,
% without any warranty.
%
% Created by Trey Hunner and substantially refactored for this project
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\NeedsTeXFormat{LaTeX2e}[2022-06-01]
\ProvidesClass{CV}[2026/09/01 v3.0 Data-driven CV class]

\LoadClass[11pt,a4paper]{article}

\RequirePackage[T1]{fontenc}
\RequirePackage[english]{babel}
\RequirePackage{lmodern}
\RequirePackage[
  left=0.4in,
  top=0.4in,
  right=0.4in,
  bottom=0.4in
]{geometry}
\RequirePackage{array}
\RequirePackage{tabularx}
\RequirePackage{enumitem}
\RequirePackage{needspace}
\RequirePackage{xcolor}
\RequirePackage{graphicx}
\RequirePackage{tikz}
\RequirePackage{hyperref}

\definecolor{cvlink}{HTML}{185A8D}
\definecolor{cvmuted}{HTML}{555555}

\hypersetup{
  colorlinks=true,
  urlcolor=cvlink,
  linkcolor=cvlink
}
\urlstyle{same}

\pagestyle{empty}
\setlength{\parindent}{0pt}
\setlength{\parskip}{0pt}
\setlist[itemize]{
  leftmargin=1.35em,
  itemsep=0.05em,
  topsep=0.1em,
  parsep=0pt,
  partopsep=0pt
}

\ExplSyntaxOn

% -----------------------------------------------------------------------------
% Data model
% -----------------------------------------------------------------------------

\tl_new:N \g_cv_name_tl
\tl_new:N \g_cv_headline_tl
\tl_new:N \g_cv_profile_tl
\tl_new:N \g_cv_photo_tl
\tl_new:N \g_cv_photo_width_tl
\tl_new:N \g_cv_career_interest_tl

\seq_new:N \g_cv_contact_seq
\seq_new:N \g_cv_education_seq
\seq_new:N \g_cv_experience_seq
\seq_new:N \g_cv_project_seq
\seq_new:N \g_cv_skill_seq
\seq_new:N \g_cv_language_seq
\seq_new:N \g_cv_quality_seq
\seq_new:N \g_cv_interest_seq
\seq_new:N \g_cv_achievement_seq

% Header and profile declarations.
\NewDocumentCommand{\name}{m}
  { \tl_gset:Nn \g_cv_name_tl {#1} }
\NewDocumentCommand{\headline}{m}
  { \tl_gset:Nn \g_cv_headline_tl {#1} }
\NewDocumentCommand{\phone}{m}
  { \seq_gput_right:Nn \g_cv_contact_seq { \cv_contact_text:n {#1} } }
\NewDocumentCommand{\address}{m}
  { \seq_gput_right:Nn \g_cv_contact_seq { \cv_contact_text:n {#1} } }
\NewDocumentCommand{\email}{m}
  { \seq_gput_right:Nn \g_cv_contact_seq { \cv_contact_email:n {#1} } }
\NewDocumentCommand{\profilelink}{m m}
  { \seq_gput_right:Nn \g_cv_contact_seq { \cv_contact_link:nn {#1} {#2} } }
\NewDocumentCommand{\weblink}{m m}
  { \href{#2}{#1} }
\NewDocumentCommand{\profile}{+m}
  { \tl_gset:Nn \g_cv_profile_tl {#1} }
\NewDocumentCommand{\photo}{m m}
  {
    \tl_gset:Nn \g_cv_photo_tl {#1}
    \tl_gset:Nn \g_cv_photo_width_tl {#2}
  }
\NewDocumentCommand{\careerinterest}{m}
  { \tl_gset:Nn \g_cv_career_interest_tl {#1} }

% Entry declarations. Key lists are stored verbatim and parsed only when the
% document is rendered, so nested semantic list commands remain unexpanded.
\NewDocumentCommand{\education}{+m}
  { \seq_gput_right:Nn \g_cv_education_seq {#1} }
\NewDocumentCommand{\experience}{+m}
  { \seq_gput_right:Nn \g_cv_experience_seq {#1} }
\NewDocumentCommand{\project}{+m}
  { \seq_gput_right:Nn \g_cv_project_seq {#1} }
\NewDocumentCommand{\skill}{m}
  { \seq_gput_right:Nn \g_cv_skill_seq {#1} }
\NewDocumentCommand{\spokenlanguage}{+m}
  { \seq_gput_right:Nn \g_cv_language_seq {#1} }
\NewDocumentCommand{\personalquality}{m}
  { \seq_gput_right:Nn \g_cv_quality_seq {#1} }
\NewDocumentCommand{\interest}{m}
  { \seq_gput_right:Nn \g_cv_interest_seq {#1} }
\NewDocumentCommand{\achievement}{+m}
  { \seq_gput_right:Nn \g_cv_achievement_seq {#1} }

% Semantic child declarations. Their visual representation is owned here.
\NewDocumentCommand{\course}{m m}
  { \item \textbf{#1}:~#2 }
\NewDocumentCommand{\educationskill}{m m}
  { \item \textbf{#1}:~#2 }
\NewDocumentCommand{\experienceskill}{m m}
  { \item \textbf{#1}:~#2 }
\NewDocumentCommand{\projectdetail}{m}
  { \seq_put_right:Nn \l_cv_project_details_seq {#1} }
\NewDocumentCommand{\projectmetric}{m m m}
  {
    \tl_if_blank:nTF {#3}
      {
        \seq_put_right:Nn \l_cv_project_metrics_seq
          {\textbf{#1}:~#2}
      }
      {
        \seq_put_right:Nn \l_cv_project_metrics_seq
          {\textbf{#1}:~#2~---~#3}
      }
  }
\NewDocumentCommand{\achievementdetail}{m O{}}
  {
    \item
    \tl_if_blank:nTF {#2}
      {#1}
      {
        \begin{tabularx}{\linewidth}
          {@{}>{\raggedright\arraybackslash}X >{\raggedleft\arraybackslash}p{0.22\linewidth}@{}}
          #1 & #2
        \end{tabularx}
      }
  }

% -----------------------------------------------------------------------------
% Education fields
% -----------------------------------------------------------------------------

\tl_new:N \l_cv_education_institution_tl
\tl_new:N \l_cv_education_url_tl
\tl_new:N \l_cv_education_program_tl
\tl_new:N \l_cv_education_start_tl
\tl_new:N \l_cv_education_end_tl
\tl_new:N \l_cv_education_end_status_tl
\tl_new:N \l_cv_education_grade_tl
\tl_new:N \l_cv_education_description_tl
\tl_new:N \l_cv_education_skills_tl
\tl_new:N \l_cv_education_courses_tl

\keys_define:nn { cv / education }
  {
    institution     .tl_set:N = \l_cv_education_institution_tl,
    institution-url .tl_set:N = \l_cv_education_url_tl,
    program         .tl_set:N = \l_cv_education_program_tl,
    start           .tl_set:N = \l_cv_education_start_tl,
    end             .tl_set:N = \l_cv_education_end_tl,
    end-status      .choice:,
    end-status / completed .code:n =
      { \tl_set:Nn \l_cv_education_end_status_tl {completed} },
    end-status / expected .code:n =
      { \tl_set:Nn \l_cv_education_end_status_tl {expected} },
    end-status / absent .code:n =
      { \tl_set:Nn \l_cv_education_end_status_tl {absent} },
    grade           .tl_set:N = \l_cv_education_grade_tl,
    description     .tl_set:N = \l_cv_education_description_tl,
    skills          .tl_set:N = \l_cv_education_skills_tl,
    courses         .tl_set:N = \l_cv_education_courses_tl
  }

% -----------------------------------------------------------------------------
% Experience fields
% -----------------------------------------------------------------------------

\tl_new:N \l_cv_experience_company_tl
\tl_new:N \l_cv_experience_url_tl
\tl_new:N \l_cv_experience_position_tl
\tl_new:N \l_cv_experience_context_tl
\tl_new:N \l_cv_experience_start_tl
\tl_new:N \l_cv_experience_end_tl
\tl_new:N \l_cv_experience_end_status_tl
\tl_new:N \l_cv_experience_description_tl
\tl_new:N \l_cv_experience_skills_tl

\keys_define:nn { cv / experience }
  {
    company     .tl_set:N = \l_cv_experience_company_tl,
    company-url .tl_set:N = \l_cv_experience_url_tl,
    position    .tl_set:N = \l_cv_experience_position_tl,
    context     .tl_set:N = \l_cv_experience_context_tl,
    start       .tl_set:N = \l_cv_experience_start_tl,
    end         .tl_set:N = \l_cv_experience_end_tl,
    end-status  .choice:,
    end-status / completed .code:n =
      { \tl_set:Nn \l_cv_experience_end_status_tl {completed} },
    end-status / expected .code:n =
      { \tl_set:Nn \l_cv_experience_end_status_tl {expected} },
    end-status / ongoing .code:n =
      { \tl_set:Nn \l_cv_experience_end_status_tl {ongoing} },
    end-status / absent .code:n =
      { \tl_set:Nn \l_cv_experience_end_status_tl {absent} },
    description .tl_set:N = \l_cv_experience_description_tl,
    skills      .tl_set:N = \l_cv_experience_skills_tl
  }

% -----------------------------------------------------------------------------
% Project fields
% -----------------------------------------------------------------------------

\tl_new:N \l_cv_project_name_tl
\tl_new:N \l_cv_project_organisation_tl
\tl_new:N \l_cv_project_organisation_url_tl
\tl_new:N \l_cv_project_date_tl
\tl_new:N \l_cv_project_description_tl
\tl_new:N \l_cv_project_items_tl
\seq_new:N \l_cv_project_details_seq
\seq_new:N \l_cv_project_metrics_seq

\keys_define:nn { cv / project }
  {
    name             .tl_set:N = \l_cv_project_name_tl,
    organisation     .tl_set:N = \l_cv_project_organisation_tl,
    organisation-url .tl_set:N = \l_cv_project_organisation_url_tl,
    date             .tl_set:N = \l_cv_project_date_tl,
    description      .tl_set:N = \l_cv_project_description_tl,
    items            .tl_set:N = \l_cv_project_items_tl
  }

% -----------------------------------------------------------------------------
% Language fields
% -----------------------------------------------------------------------------

\tl_new:N \l_cv_language_name_tl
\tl_new:N \l_cv_language_level_tl

\keys_define:nn { cv / language }
  {
    name  .tl_set:N = \l_cv_language_name_tl,
    level .tl_set:N = \l_cv_language_level_tl
  }

% -----------------------------------------------------------------------------
% Achievement fields
% -----------------------------------------------------------------------------

\tl_new:N \l_cv_achievement_title_tl
\tl_new:N \l_cv_achievement_organisation_tl
\tl_new:N \l_cv_achievement_organisation_url_tl
\tl_new:N \l_cv_achievement_date_tl
\tl_new:N \l_cv_achievement_description_tl
\tl_new:N \l_cv_achievement_details_tl

\keys_define:nn { cv / achievement }
  {
    title            .tl_set:N = \l_cv_achievement_title_tl,
    organisation     .tl_set:N = \l_cv_achievement_organisation_tl,
    organisation-url .tl_set:N = \l_cv_achievement_organisation_url_tl,
    date             .tl_set:N = \l_cv_achievement_date_tl,
    description      .tl_set:N = \l_cv_achievement_description_tl,
    details          .tl_set:N = \l_cv_achievement_details_tl
  }

% -----------------------------------------------------------------------------
% Validation and shared formatting
% -----------------------------------------------------------------------------

\cs_new_protected:Npn \cv_require_field:Nn #1#2
  {
    \tl_if_blank:VTF #1
      {
        \ClassError{CV}
          {Missing~required~field~'#2'}
          {Add~the~'#2'~key~to~the~corresponding~CV~entry.}
      }
      { }
  }

\cs_new_protected:Npn \cv_contact_text:n #1 {#1}
\cs_new_protected:Npn \cv_contact_email:n #1
  { \href{mailto:#1}{#1} }
\cs_new_protected:Npn \cv_contact_link:nn #1#2
  { \href{#2}{#1} }

\cs_new_protected:Npn \cv_link_or_text:NN #1#2
  {
    \tl_if_blank:VTF #2
      { \tl_use:N #1 }
      { \href{\tl_use:N #2}{\textcolor{cyan}{\textup{\tl_use:N #1}}} }
  }

\cs_new:Npn \cv_date_range:NNN #1#2#3
  {
    \tl_use:N #1
    \tl_if_eq:VnTF #3 {absent}
      { }
      {
        \space--\space
        \tl_if_eq:VnTF #3 {ongoing}
          {Present}
          {
            \tl_use:N #2
            \tl_if_eq:VnTF #3 {expected}
              {\space(expected)}
              { }
          }
      }
  }

\cs_new:Npn \cv_role_with_context:NN #1#2
  {
    \tl_use:N #1
    \tl_if_blank:VTF #2
      { }
      {\space---\space\tl_use:N #2}
  }

\cs_new_protected:Npn \cv_section:n #1
  {
    \Needspace{3\baselineskip}
    \par\addvspace{0.35\baselineskip}
    \cv_section_heading:n {#1}
  }

\cs_new_protected:Npn \cv_section_heading:n #1
  {
    {\bfseries\MakeUppercase{#1}\par}
    \vspace{0.18em}
    \hrule
    \vspace{0.55em}
  }

\cs_new_protected:Npn \cv_entry_description:n #1
  { {\small #1\par} }

\cs_new_protected:Npn \cv_entry_items:n #1
  { \cv_entry_items:nn {\textbullet} {#1} }

\cs_new_protected:Npn \cv_entry_items:nn #1#2
  {
    {\small
      \begin{itemize}[label={#1}]
        #2
      \end{itemize}
    }
  }

\cs_new_protected:Npn \cv_entry_end:
  { \par\addvspace{0.55em} }

\cs_new_protected:Npn \cv_skill_box:n #1
  {
    \tikz[baseline=(cvskill.base)]
      \node[
        rectangle,
        rounded~corners=3pt,
        draw=cvmuted,
        fill=black!4,
        line~width=0.35pt,
        inner~xsep=0.55em,
        inner~ysep=0.28em,
        outer~sep=0pt
      ] (cvskill) {\footnotesize #1};
  }

\cs_new_protected:Npn \cv_render_skill_boxes:
  {
    \group_begin:
      \raggedright
      \seq_map_inline:Nn \g_cv_skill_seq
        {
          \cv_skill_box:n {##1}
          \hspace{0.3em}\allowbreak
        }
      \par
    \group_end:
  }

\box_new:N \l_cv_profile_measure_box
\box_new:N \l_cv_skills_measure_box
\dim_new:N \l_cv_profile_width_dim
\dim_new:N \l_cv_skills_width_dim
\dim_new:N \l_cv_photo_width_dim
\dim_new:N \l_cv_top_available_width_dim
\dim_new:N \l_cv_top_gap_dim
\dim_new:N \l_cv_profile_height_dim
\dim_new:N \l_cv_skills_height_dim
\dim_new:N \l_cv_balance_low_dim
\dim_new:N \l_cv_balance_high_dim
\dim_new:N \l_cv_balance_mid_dim
\dim_new:N \l_cv_balance_diff_dim
\dim_new:N \l_cv_balance_best_diff_dim
\dim_new:N \l_cv_balance_best_profile_width_dim

\cs_new_protected:Npn \cv_profile_block:
  {
    \vspace{0pt}
    \cv_section_heading:n {Profile}
    \raggedright
    \tl_use:N \g_cv_profile_tl\par
  }

\cs_new_protected:Npn \cv_skills_block:
  {
    \vspace{0pt}
    \cv_section_heading:n {Hard~Skills~\&~Tools}
    \cv_render_skill_boxes:
  }

\cs_new_protected:Npn \cv_measure_top_columns:
  {
    \hbox_set:Nn \l_cv_profile_measure_box
      {
        \hbadness=10000\relax
        \begin{minipage}[t]{\dim_use:N \l_cv_profile_width_dim}
          \cv_profile_block:
        \end{minipage}
      }
    \hbox_set:Nn \l_cv_skills_measure_box
      {
        \hbadness=10000\relax
        \begin{minipage}[t]{\dim_use:N \l_cv_skills_width_dim}
          \cv_skills_block:
        \end{minipage}
      }
    \dim_set:Nn \l_cv_profile_height_dim
      {
        \box_ht:N \l_cv_profile_measure_box
        + \box_dp:N \l_cv_profile_measure_box
      }
    \dim_set:Nn \l_cv_skills_height_dim
      {
        \box_ht:N \l_cv_skills_measure_box
        + \box_dp:N \l_cv_skills_measure_box
      }
  }

\cs_new_protected:Npn \cv_balance_top_columns:
  {
    \dim_set:Nn \l_cv_balance_low_dim
      {0.30\l_cv_top_available_width_dim}
    \dim_set:Nn \l_cv_balance_high_dim
      {0.70\l_cv_top_available_width_dim}
    \dim_set:Nn \l_cv_balance_best_diff_dim {\maxdimen}
    \dim_set:Nn \l_cv_balance_best_profile_width_dim
      {0.50\l_cv_top_available_width_dim}

    \prg_replicate:nn {10}
      {
        \dim_set:Nn \l_cv_balance_mid_dim
          {0.50\l_cv_balance_low_dim + 0.50\l_cv_balance_high_dim}
        \dim_set_eq:NN
          \l_cv_profile_width_dim \l_cv_balance_mid_dim
        \dim_set:Nn \l_cv_skills_width_dim
          {\l_cv_top_available_width_dim - \l_cv_profile_width_dim}
        \cv_measure_top_columns:

        \dim_compare:nNnTF
          {\l_cv_profile_height_dim} > {\l_cv_skills_height_dim}
          {
            \dim_set:Nn \l_cv_balance_diff_dim
              {\l_cv_profile_height_dim - \l_cv_skills_height_dim}
            \dim_set_eq:NN
              \l_cv_balance_low_dim \l_cv_balance_mid_dim
          }
          {
            \dim_set:Nn \l_cv_balance_diff_dim
              {\l_cv_skills_height_dim - \l_cv_profile_height_dim}
            \dim_set_eq:NN
              \l_cv_balance_high_dim \l_cv_balance_mid_dim
          }

        \dim_compare:nNnT
          {\l_cv_balance_diff_dim} < {\l_cv_balance_best_diff_dim}
          {
            \dim_set_eq:NN
              \l_cv_balance_best_diff_dim \l_cv_balance_diff_dim
            \dim_set_eq:NN
              \l_cv_balance_best_profile_width_dim
              \l_cv_profile_width_dim
          }
      }

    \dim_set_eq:NN
      \l_cv_profile_width_dim \l_cv_balance_best_profile_width_dim
    \dim_set:Nn \l_cv_skills_width_dim
      {\l_cv_top_available_width_dim - \l_cv_profile_width_dim}
  }

\cs_new_protected:Npn \cv_set_photo_width:
  {
    \tl_if_blank:VTF \g_cv_photo_width_tl
      {
        \ClassError{CV}
          {Missing~photo~width}
          {Pass~a~width~as~the~second~argument~to~\string\photo.}
      }
      {
        \dim_set:Nn \l_cv_photo_width_dim
          {\tl_use:N \g_cv_photo_width_tl}
      }
    \dim_compare:nNnF {\l_cv_photo_width_dim} > {0pt}
      {
        \ClassError{CV}
          {Photo~width~must~be~positive}
          {Use~a~width~such~as~0.18\string\linewidth.}
      }
    \dim_compare:nNnF {\l_cv_photo_width_dim} < {0.30\linewidth}
      {
        \ClassError{CV}
          {Photo~width~is~too~large}
          {Use~a~width~smaller~than~0.30\string\linewidth.}
      }
  }

\cs_new_protected:Npn \cv_render_photo:
  {
    \exp_args:NV \file_if_exist:nTF \g_cv_photo_tl
      {
        \centering
        \includegraphics[width=\linewidth]
          {\tl_use:N \g_cv_photo_tl}
        \par
      }
      {
        \ClassError{CV}
          {Photo~file~'\tl_use:N \g_cv_photo_tl'~not~found}
          {Check~the~path~passed~to~\string\photo.}
      }
  }

\cs_new_protected:Npn \cv_render_profile_and_skills:
  {
    \Needspace{9\baselineskip}
    \par\addvspace{0.35\baselineskip}
    \tl_if_blank:VTF \g_cv_photo_tl
      {
        \dim_set:Nn \l_cv_top_gap_dim {0.03\linewidth}
        \dim_set:Nn \l_cv_top_available_width_dim
          {\linewidth - \l_cv_top_gap_dim}
        \cv_balance_top_columns:
        \noindent
        \begin{minipage}[t]{\dim_use:N \l_cv_profile_width_dim}
          \cv_profile_block:
        \end{minipage}
        \hspace{\dim_use:N \l_cv_top_gap_dim}
        \begin{minipage}[t]{\dim_use:N \l_cv_skills_width_dim}
          \cv_skills_block:
        \end{minipage}
      }
      {
        \cv_set_photo_width:
        \dim_set:Nn \l_cv_top_gap_dim {0.025\linewidth}
        \dim_set:Nn \l_cv_top_available_width_dim
          {
            \linewidth - \l_cv_photo_width_dim
            - 2\l_cv_top_gap_dim
          }
        \cv_balance_top_columns:
        \noindent
        \begin{minipage}[t]{\dim_use:N \l_cv_profile_width_dim}
          \cv_profile_block:
        \end{minipage}
        \hspace{\dim_use:N \l_cv_top_gap_dim}
        \begin{minipage}[t]{\dim_use:N \l_cv_skills_width_dim}
          \cv_skills_block:
        \end{minipage}
        \hspace{\dim_use:N \l_cv_top_gap_dim}
        \begin{minipage}[t]{\dim_use:N \l_cv_photo_width_dim}
          \vspace{0pt}
          \cv_render_photo:
        \end{minipage}
      }
    \par
  }

\cs_new_protected:Npn \cv_entry_header:nnnn #1#2#3#4
  {
    \begin{tabularx}{\linewidth}
      {@{}>{\raggedright\arraybackslash}X >{\raggedleft\arraybackslash}p{0.31\linewidth}@{}}
      {\bfseries #1} & #3 \\
      {\itshape #2} & {\itshape #4}
    \end{tabularx}
    \par
    \vspace{0.12em}
  }

\cs_new_protected:Npn \cv_entry_header:nn #1#2
  {
    \begin{tabularx}{\linewidth}
      {@{}>{\raggedright\arraybackslash}X >{\raggedleft\arraybackslash}p{0.31\linewidth}@{}}
      {\bfseries #1} & #2
    \end{tabularx}
    \par
  }

\cs_new_protected:Npn \cv_render_header:
  {
    \hypersetup{
      pdftitle={Curriculum~Vitae~--~\tl_use:N \g_cv_name_tl},
      pdfauthor={\tl_use:N \g_cv_name_tl}
    }
    \par
    {\centering
      {\LARGE\bfseries\MakeUppercase{\tl_use:N \g_cv_name_tl}\par}
      \tl_if_blank:VTF \g_cv_headline_tl
        { }
        {\vspace{0.05em}\tl_use:N \g_cv_headline_tl\par}
      \seq_if_empty:NF \g_cv_contact_seq
        {
          \vspace{0.05em}
          {\small
            \seq_use:Nn \g_cv_contact_seq
              {\enspace\textcolor{cvmuted}{$\diamond$}\enspace}
            \par
          }
        }
    }
  }

% -----------------------------------------------------------------------------
% Entry renderers
% -----------------------------------------------------------------------------

\cs_new_protected:Npn \cv_render_education:n #1
  {
    \group_begin:
      \tl_set:Nn \l_cv_education_end_status_tl {completed}
      \keys_set:nn { cv / education } {#1}
      \cv_require_field:Nn \l_cv_education_institution_tl {institution}
      \cv_require_field:Nn \l_cv_education_program_tl {program}
      \cv_require_field:Nn \l_cv_education_start_tl {start}
      \tl_if_eq:VnTF \l_cv_education_end_status_tl {absent}
        { }
        {\cv_require_field:Nn \l_cv_education_end_tl {end}}
      \cv_require_field:Nn \l_cv_education_description_tl {description}
      \Needspace{5\baselineskip}
      \cv_entry_header:nnnn
        {\tl_use:N \l_cv_education_program_tl}
        {\cv_link_or_text:NN
          \l_cv_education_institution_tl \l_cv_education_url_tl}
        {\cv_date_range:NNN
          \l_cv_education_start_tl
          \l_cv_education_end_tl
          \l_cv_education_end_status_tl}
        {
          \tl_if_blank:VTF \l_cv_education_grade_tl
            { }
            {Grade:~\tl_use:N \l_cv_education_grade_tl}
        }
      \cv_entry_description:n
        {\tl_use:N \l_cv_education_description_tl}
      \tl_if_blank:VTF \l_cv_education_courses_tl
        { }
        {
          \cv_entry_items:n
            {
            \tl_use:N \l_cv_education_courses_tl
            }
        }
      \tl_if_blank:VTF \l_cv_education_skills_tl
        { }
        {
          \cv_entry_items:nn {--}
            {
            \tl_use:N \l_cv_education_skills_tl
            }
        }
      \cv_entry_end:
    \group_end:
  }

\cs_new_protected:Npn \cv_render_experience:n #1
  {
    \group_begin:
      \tl_set:Nn \l_cv_experience_end_status_tl {completed}
      \keys_set:nn { cv / experience } {#1}
      \cv_require_field:Nn \l_cv_experience_position_tl {position}
      \cv_require_field:Nn \l_cv_experience_start_tl {start}
      \tl_if_eq:VnTF \l_cv_experience_end_status_tl {ongoing}
        { }
        {
          \tl_if_eq:VnTF \l_cv_experience_end_status_tl {absent}
            { }
            {\cv_require_field:Nn \l_cv_experience_end_tl {end}}
        }
      \cv_require_field:Nn \l_cv_experience_description_tl {description}
      \cv_require_field:Nn \l_cv_experience_skills_tl {skills}
      \Needspace{6\baselineskip}
      \tl_if_blank:VTF \l_cv_experience_company_tl
        {
          \cv_entry_header:nn
            {\cv_role_with_context:NN
              \l_cv_experience_position_tl
              \l_cv_experience_context_tl}
            {\cv_date_range:NNN
              \l_cv_experience_start_tl
              \l_cv_experience_end_tl
              \l_cv_experience_end_status_tl}
        }
        {
          \cv_entry_header:nnnn
            {\cv_role_with_context:NN
              \l_cv_experience_position_tl
              \l_cv_experience_context_tl}
            {\cv_link_or_text:NN
              \l_cv_experience_company_tl \l_cv_experience_url_tl}
            {\cv_date_range:NNN
              \l_cv_experience_start_tl
              \l_cv_experience_end_tl
              \l_cv_experience_end_status_tl}
            { }
        }
      \cv_entry_description:n
        {\tl_use:N \l_cv_experience_description_tl}
      \cv_entry_items:n
        {\tl_use:N \l_cv_experience_skills_tl}
      \cv_entry_end:
    \group_end:
  }

\cs_new_protected:Npn \cv_render_project:n #1
  {
    \group_begin:
      \seq_clear:N \l_cv_project_details_seq
      \seq_clear:N \l_cv_project_metrics_seq
      \keys_set:nn { cv / project } {#1}
      \cv_require_field:Nn \l_cv_project_name_tl {name}
      \cv_require_field:Nn \l_cv_project_date_tl {date}
      \cv_require_field:Nn \l_cv_project_description_tl {description}
      \cv_require_field:Nn \l_cv_project_items_tl {items}
      \tl_use:N \l_cv_project_items_tl
      \Needspace{6\baselineskip}
      \tl_if_blank:VTF \l_cv_project_organisation_tl
        {
          \cv_entry_header:nn
            {\tl_use:N \l_cv_project_name_tl}
            {\tl_use:N \l_cv_project_date_tl}
        }
        {
          \cv_entry_header:nnnn
            {\tl_use:N \l_cv_project_name_tl}
            {\cv_link_or_text:NN
              \l_cv_project_organisation_tl
              \l_cv_project_organisation_url_tl}
            {\tl_use:N \l_cv_project_date_tl}
            { }
        }
      \cv_entry_description:n
        {\tl_use:N \l_cv_project_description_tl}
      \seq_if_empty:NF \l_cv_project_metrics_seq
        {
          \cv_entry_items:n
            {
              \seq_map_inline:Nn \l_cv_project_metrics_seq
                {\item ##1}
            }
        }
      \seq_if_empty:NF \l_cv_project_details_seq
        {
          \cv_entry_items:nn {--}
            {
              \seq_map_inline:Nn \l_cv_project_details_seq
                {\item ##1}
            }
        }
      \cv_entry_end:
    \group_end:
  }

\cs_new_protected:Npn \cv_render_language:n #1
  {
    \group_begin:
      \keys_set:nn { cv / language } {#1}
      \cv_require_field:Nn \l_cv_language_name_tl {name}
      \cv_require_field:Nn \l_cv_language_level_tl {level}
      \cv_skill_box:n {\tl_use:N \l_cv_language_name_tl}~
      \tl_use:N \l_cv_language_level_tl
    \group_end:
  }

\cs_new_protected:Npn \cv_render_achievement:n #1
  {
    \group_begin:
      \keys_set:nn { cv / achievement } {#1}
      \cv_require_field:Nn \l_cv_achievement_title_tl {title}
      \cv_require_field:Nn \l_cv_achievement_date_tl {date}
      \Needspace{4\baselineskip}
      \tl_if_blank:VTF \l_cv_achievement_organisation_tl
        {
          \cv_entry_header:nn
            {\tl_use:N \l_cv_achievement_title_tl}
            {\tl_use:N \l_cv_achievement_date_tl}
        }
        {
          \cv_entry_header:nnnn
            {\tl_use:N \l_cv_achievement_title_tl}
            {\cv_link_or_text:NN
              \l_cv_achievement_organisation_tl
              \l_cv_achievement_organisation_url_tl}
            {\tl_use:N \l_cv_achievement_date_tl}
            { }
        }
      \tl_if_blank:VTF \l_cv_achievement_description_tl
        { }
        {
          \cv_entry_description:n
            {\tl_use:N \l_cv_achievement_description_tl}
        }
      \tl_if_blank:VTF \l_cv_achievement_details_tl
        { }
        {
          \cv_entry_items:n
            {\tl_use:N \l_cv_achievement_details_tl}
        }
      \cv_entry_end:
    \group_end:
  }

% -----------------------------------------------------------------------------
% Complete document renderer
% -----------------------------------------------------------------------------

\cs_new_protected:Npn \cv_render_document:
  {
    \cv_require_field:Nn \g_cv_name_tl {name}
    \cv_render_header:

    \tl_if_blank:VTF \g_cv_profile_tl
      {
        \seq_if_empty:NF \g_cv_skill_seq
          {
            \cv_section:n {Hard~Skills~\&~Tools}
            \cv_render_skill_boxes:
          }
      }
      {
        \seq_if_empty:NTF \g_cv_skill_seq
          {
            \cv_section:n {Profile}
            \tl_use:N \g_cv_profile_tl\par
          }
          {\cv_render_profile_and_skills:}
      }

    \seq_if_empty:NF \g_cv_education_seq
      {
        \cv_section:n {Education}
        \seq_map_inline:Nn \g_cv_education_seq
          {\cv_render_education:n {##1}}
      }

    \seq_if_empty:NF \g_cv_experience_seq
      {
        \cv_section:n {Work~Experience}
        \seq_map_inline:Nn \g_cv_experience_seq
          {\cv_render_experience:n {##1}}
      }

    \seq_if_empty:NF \g_cv_project_seq
      {
        \Needspace{18\baselineskip}
        \cv_section:n {Projects}
        \seq_map_inline:Nn \g_cv_project_seq
          {\cv_render_project:n {##1}}
      }

    \bool_set_false:N \l_tmpa_bool
    \seq_if_empty:NF \g_cv_language_seq
      {\bool_set_true:N \l_tmpa_bool}
    \tl_if_blank:VTF \g_cv_career_interest_tl
      { }
      {\bool_set_true:N \l_tmpa_bool}
    \seq_if_empty:NF \g_cv_quality_seq
      {\bool_set_true:N \l_tmpa_bool}
    \seq_if_empty:NF \g_cv_interest_seq
      {\bool_set_true:N \l_tmpa_bool}
    \bool_if:NT \l_tmpa_bool
      {
        \cv_section:n {Additional~Information}
        \seq_if_empty:NF \g_cv_language_seq
          {
            \noindent\textbf{Languages}:~
            \seq_map_indexed_inline:Nn \g_cv_language_seq
              {
                \int_compare:nNnT {##1} > {1} {;~}
                \cv_render_language:n {##2}
              }
            \par
          }
        \tl_if_blank:VTF \g_cv_career_interest_tl
          { }
          {
            \noindent\textbf{Career~interests}:~
              \tl_use:N \g_cv_career_interest_tl\par
          }
        \seq_if_empty:NF \g_cv_quality_seq
          {
            \noindent\textbf{Personal~qualities}:~
              \seq_use:Nn \g_cv_quality_seq {;~}\par
          }
        \seq_if_empty:NF \g_cv_interest_seq
          {
            \noindent\textbf{Interests}:~
              \seq_use:Nn \g_cv_interest_seq {,~}\par
          }
      }

    \seq_if_empty:NF \g_cv_achievement_seq
      {
        \cv_section:n {Other~Achievements}
        \seq_map_inline:Nn \g_cv_achievement_seq
          {\cv_render_achievement:n {##1}}
      }
  }

\AtBeginDocument{\cv_render_document:}

\ExplSyntaxOff
