%% ORD CESER PDF Template
%% Version 1.0
%% By Andrew Murray
%% Updated May 16, 2024

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{ceser_pdf}


%% Colors & Graphics
\usepackage{xcolor}
\usepackage{graphicx}
\usepackage{tikz}
\usepackage[absolute]{textpos}
\usepackage[most]{tcolorbox}

%% Font
\def\normalsize{}{\fontsize{12pt}{14pt}\selectfont} % defines \normalsize
\makeatletter
\let\@currsize\normalsize % defines \@currsize
\makeatother

\usepackage{fontspec}
\setmainfont{calibri}
\setsansfont{calibri}


\usepackage[T1]{fontenc}
\usepackage[utf8]{inputenc}
\usepackage{textcomp} % for the copyright symbol
\RequirePackage{bera}
\RequirePackage[charter,expert]{mathdesign}
\RequirePackage[scale=0.9]{sourcecodepro}
\RequirePackage[lf,t]{FiraSans}
%\usepackage[fontsize=12pt]{fontsize}

%% Page dimensions
\usepackage[a4paper,left=1in,right=1in,top=1in,bottom=1in]{geometry}

% text box setup
\setlength{\TPHorizModule}{0.25in}
\setlength{\TPVertModule}{\TPHorizModule}
\textblockorigin{0in}{0in}


%% CAPTIONS
\RequirePackage{caption}
\DeclareCaptionStyle{italic}[justification=centering]
 {labelfont={bf},textfont={it},labelsep=colon}
\captionsetup[figure]{style=italic,format=hang,singlelinecheck=true}
\captionsetup[table]{style=italic,format=hang,singlelinecheck=true}

%% Define Colors
\definecolor{epagreen}{HTML}{00673E}
\definecolor{darkblue}{rgb}{0,0,0} % Carolina blue: 0.29,0.61,.83

%% format the cover
\def\titlepage{\sf
  \pagecolor{epagreen}

  % EPA Logo
  \begin{tikzpicture}[remember picture,overlay,shift={(current page.north west)}]
  \node[anchor=north west,xshift=0.93in,yshift=-0.43in]{\includegraphics[width=2in]{_extensions/ORD_ceser/img/epa_logo_vert_white.png}};
  \end{tikzpicture}
  
  % Report Number
  \begin{textblock}{16}(19,2)
  \textcolor{white}{$report-no$ | $month$ $year$ | www.epa.gov/research}
  \end{textblock}
  
  % Title
  \begin{textblock}{16}(4,22)
  \textcolor{white}{$title$}
  \end{textblock}
  
  % Cover Image
  \begin{tikzpicture}[remember picture,overlay,shift={(current page.north west)}]
  \node[anchor=north west,xshift=-0.05in,yshift=-4in]{\includegraphics[width=\paperwidth]{$cover-img$}};
  \end{tikzpicture}

  }



%% MATHS
\RequirePackage{bm,amsmath}
\allowdisplaybreaks

%% FONT
% \usepackage[T1]{fontenc}
% \usepackage[utf8]{inputenc}
\usepackage{textcomp} % for the copyright symbol
% \RequirePackage{bera}
% \RequirePackage[charter,expert]{mathdesign}
% \RequirePackage[scale=0.9]{sourcecodepro}
% \RequirePackage[lf,t]{FiraSans}


\ProcessOptions

%% Text wrapping for code
\usepackage{listings}

% Define a new environment for code listings with line wrapping
\lstnewenvironment{wrappedcode}[1][]{
    \lstset{
        basicstyle=\ttfamily,
        breaklines=true,
        breakindent=2em, % Adjust the indentation as needed
        postbreak=\mbox{\textcolor{red}{$\hookrightarrow$}\space}, % Optional: Add a symbol at line breaks
        #1 % Any additional settings you want to pass
    }
}{}


%% CAPTIONS
\RequirePackage{caption}
\DeclareCaptionStyle{italic}[justification=centering]
 {labelfont={bf},textfont={it},labelsep=colon}
\captionsetup[figure]{style=italic,format=hang,singlelinecheck=true}
\captionsetup[table]{style=italic,format=hang,singlelinecheck=true}

%% plain page style
\pagestyle{plain}

%% FIGURE PLACEMENT
\usepackage{float}

%% SECTION HEADERS
% \usepackage{sectsty}
% \allsectionsfont{\centering\fontsize{12}{14}\sf}

%% GRAPHICS
\RequirePackage{graphicx}
\setcounter{topnumber}{2}
\setcounter{bottomnumber}{2}
\setcounter{totalnumber}{4}
\renewcommand{\topfraction}{0.85}
\renewcommand{\bottomfraction}{0.85}
\renewcommand{\textfraction}{0.15}
\renewcommand{\floatpagefraction}{0.7}

\RequirePackage[section]{placeins}

%% LIST OF FIGURES
\usepackage{tocloft}

%% Get rid of Appendix prefix
% \usepackage[toc]{appendix}
% \renewcommand{\appendixtocname}{List of Appendices}


%% SECTION TITLES
\RequirePackage[compact,sf,bf]{titlesec}
\titleformat{\section}[block]
  {\vspace*{1in}}
  {\fontsize{12}{14}\bfseries\sffamily}
  {\thesection}
  {0.4em}{}
\titleformat{\subsection}[block]
  {\fontsize{12}{14}\bfseries\sffamily}
  {\thesubsection}
  {0.4em}{}
\titlespacing{\section}{0pt}{*2}{*0.2}
\titlespacing{\subsubsection}{0pt}{1ex}{0ex}
\titleformat{\subsubsection}{\bf}{}{0ex}{}

%% SPACING
\RequirePackage{setspace}
\setstretch{2}

%% LINE AND PAGE BREAKING
\sloppy
\clubpenalty = 10000
\widowpenalty = 10000
\brokenpenalty = 10000
\RequirePackage{microtype}
\RequirePackage{ragged2e}

%% BIBLIOGRAPHY
\usepackage{natbib}

%% PARAGRAPH BREAKS
\setlength{\parskip}{1.4ex}
\setlength{\parindent}{2em}

%% HYPERLINKS
%\RequirePackage{xcolor} % Needed for links
\RequirePackage{url}
\RequirePackage[citecolor=0 0 0,colorlinks=false]{hyperref}
\hypersetup{
     breaklinks=true,
     bookmarksopen=true,
     bookmarksnumbered=true,
     linkcolor=darkblue,
     urlcolor=blue,
     citecolor=darkblue,
     colorlinks=true}
\usepackage{bookmark}


%% load packages to make Abbreviations table
\usepackage{longtable}
\usepackage{array}


\numberwithin{section}{chapter}
\numberwithin{equation}{chapter}

\setcounter{tocdepth}{3}
%\setcounter{secnumdepth}{3}

\def\cleardoublepage{\clearpage\if@twoside \ifodd\c@page\else
\hbox{}
\vspace*{\fill}
\thispagestyle{empty}
\newpage
\if@twocolumn\hbox{}\newpage\fi\fi\fi}


%% Table of contents
\def\tighttoc
    {
        \thispagestyle{plain}
        \centering
        \renewcommand{\contentsname}{\fontsize{12}{14}\sf Table of Contents}
        \dimen100 = \parskip
        \setlength{\parskip}{0pt}
        \tableofcontents
        \setlength{\parskip}{\dimen100}
    }


% to display the bibliography in table of contents
\usepackage[nottoc,notlot,notlof]{tocbibind}
%\usepackage{tocloft}
\renewcommand{\cftchappagefont}{\sffamily\bfseries}
\renewcommand{\cftchapfont}{\sffamily\bfseries}
\renewcommand{\cftsecpagefont}{\sffamily}
\renewcommand{\cftsubsecpagefont}{\sffamily}
\renewcommand{\cftsecfont}{\sffamily}
\renewcommand{\cftsubsecfont}{\sffamily}
\renewcommand{\cfttoctitlefont}{\fontsize{12}{14}\sffamily\bfseries}
%\renewcommand{\bibname}{References}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extra stuff for Rmarkdown to work
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\providecommand{\tightlist}{%
  \setlength{\itemsep}{0pt}\setlength{\parskip}{0pt}}
\usepackage{framed}
\definecolor{shadecolor}{RGB}{248,248,248}
\newenvironment{Shaded}{\begin{snugshade}}{\end{snugshade}}
\usepackage{fancyvrb}
\newcommand{\VerbBar}{|}
\newcommand{\VERB}{\Verb[commandchars=\\\{\}]}
\DefineVerbatimEnvironment{verbatim}{Verbatim}{xleftmargin=0em}
\DefineVerbatimEnvironment{Highlighting}{Verbatim}{xleftmargin=0em,commandchars=\\\{\}}

\newcommand{\KeywordTok}[1]{\textcolor[rgb]{0.13,0.29,0.53}{\textbf{{#1}}}}
\newcommand{\DataTypeTok}[1]{\textcolor[rgb]{0.13,0.29,0.53}{{#1}}}
\newcommand{\DecValTok}[1]{\textcolor[rgb]{0.00,0.00,0.81}{{#1}}}
\newcommand{\BaseNTok}[1]{\textcolor[rgb]{0.00,0.00,0.81}{{#1}}}
\newcommand{\FloatTok}[1]{\textcolor[rgb]{0.00,0.00,0.81}{{#1}}}
\newcommand{\ConstantTok}[1]{\textcolor[rgb]{0.00,0.00,0.00}{{#1}}}
\newcommand{\CharTok}[1]{\textcolor[rgb]{0.31,0.60,0.02}{{#1}}}
\newcommand{\SpecialCharTok}[1]{\textcolor[rgb]{0.00,0.00,0.00}{{#1}}}
\newcommand{\StringTok}[1]{\textcolor[rgb]{0.31,0.60,0.02}{{#1}}}
\newcommand{\VerbatimStringTok}[1]{\textcolor[rgb]{0.31,0.60,0.02}{{#1}}}
\newcommand{\SpecialStringTok}[1]{\textcolor[rgb]{0.31,0.60,0.02}{{#1}}}
\newcommand{\ImportTok}[1]{{#1}}
\newcommand{\CommentTok}[1]{\textcolor[rgb]{0.56,0.35,0.01}{\textit{{#1}}}}
\newcommand{\DocumentationTok}[1]{\textcolor[rgb]{0.56,0.35,0.01}{\textbf{\textit{{#1}}}}}
\newcommand{\AnnotationTok}[1]{\textcolor[rgb]{0.56,0.35,0.01}{\textbf{\textit{{#1}}}}}
\newcommand{\CommentVarTok}[1]{\textcolor[rgb]{0.56,0.35,0.01}{\textbf{\textit{{#1}}}}}
\newcommand{\OtherTok}[1]{\textcolor[rgb]{0.56,0.35,0.01}{{#1}}}
\newcommand{\FunctionTok}[1]{\textcolor[rgb]{0.00,0.00,0.00}{{#1}}}
\newcommand{\VariableTok}[1]{\textcolor[rgb]{0.00,0.00,0.00}{{#1}}}
\newcommand{\ControlFlowTok}[1]{\textcolor[rgb]{0.13,0.29,0.53}{\textbf{{#1}}}}
\newcommand{\OperatorTok}[1]{\textcolor[rgb]{0.81,0.36,0.00}{\textbf{{#1}}}}
\newcommand{\BuiltInTok}[1]{{#1}}
\newcommand{\ExtensionTok}[1]{{#1}}
\newcommand{\PreprocessorTok}[1]{\textcolor[rgb]{0.56,0.35,0.01}{\textit{{#1}}}}
\newcommand{\AttributeTok}[1]{\textcolor[rgb]{0.77,0.63,0.00}{{#1}}}
\newcommand{\RegionMarkerTok}[1]{{#1}}
\newcommand{\InformationTok}[1]{\textcolor[rgb]{0.56,0.35,0.01}{\textbf{\textit{{#1}}}}}
\newcommand{\WarningTok}[1]{\textcolor[rgb]{0.56,0.35,0.01}{\textbf{\textit{{#1}}}}}
\newcommand{\AlertTok}[1]{\textcolor[rgb]{0.94,0.16,0.16}{{#1}}}
\newcommand{\ErrorTok}[1]{\textcolor[rgb]{0.64,0.00,0.00}{\textbf{{#1}}}}
\newcommand{\NormalTok}[1]{{#1}}

\usepackage{longtable,booktabs,tabu}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\raggedbottom
