# ampatchlab/nf-bam2fastq

[![Build Status](https://codebuild.ap-southeast-2.amazonaws.com/badges?uuid=eyJlbmNyeXB0ZWREYXRhIjoiSDZhcmZsSytNYk9oR3paUmEzenAxKzgwZ3dRa0c1eWROVDVlZFdLcTQ5SnNEeWl6b0xoTlNCN0RQMDlkVkFsd2dxejFnbW1VS3ZTSlBVK3dteUw2V25VPSIsIml2UGFyYW1ldGVyU3BlYyI6InVTNCtCYUFibCtRTU94Q2UiLCJtYXRlcmlhbFNldFNlcmlhbCI6MX0%3D&branch=master)](https://ap-southeast-2.console.aws.amazon.com/codesuite/codebuild/projects/nf-bam2fastq/history)
[![Nextflow](https://img.shields.io/badge/nextflow-%E2%89%A519.10.0-brightgreen.svg)](https://www.nextflow.io/)
[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

Simple BAM to FASTQ Nextflow pipeline

## Usage

```
Usage:
    nextflow run -profile <profile> -revision <revision> ampatchlab/nf-bam2fastq [options]


Nextflow execution options:

    -profile STR
        Nextflow configuration profile to use. Available profiles include:
        'awsbatch', 'conda', 'docker' and 'singularity'

    -revision STR
        Git branch/tag (version) of this workflow to use

    -work-dir DIR
        Directory where intermediate result files are stored

    -help
        Show additional execution options and exit


Input options:

    --bams PATH
        Path to input data (must be surrounded with quotes, e.g. '*.bam')


Output options:

    --outdir DIR
        Path where the results will be saved [Default: ./results]

    --format_string STR
        Output file format string [Default: "%*_%#.%."]

        Format string expansions:
          %%     %
          %*     basename
          %#     @RG index
          %!     @RG ID
          %.     filename extension for output format

    --compression_level INT
        Output file compression level [Default: 6]


Standard options:

    --advanced
        Show advanced usage and exit

    --help
        Show this message and exit

    --version
        Show the pipeline version and exit
```

## Advanced options

```
Report options:

    --execution_report STR
        Name of the Nextflow execution report to generate [Default: ./reports/execution_report.html]

    --trace_report STR
        Name of the Nextflow trace report to generate [Default: ./reports/trace_report.txt]

    --timeline_report STR
        Name of the Nextflow timeline report to generate [Default: ./reports/timeline_report.html]

    --flowchart STR
        Name of the Nextflow flowchart to generate [Default: ./reports/flowchart.png]


AWS Batch options:

    --aws_queue STR
        AWS Batch JobQueue definition [Default: false]

    --aws_region STR
        AWS Region definition [Default: false]
```
