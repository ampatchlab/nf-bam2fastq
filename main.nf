#!/usr/bin/env nextflow

/*
vim: syntax=groovy
-*- mode: groovy;-*-
 *
 * ampatchlab/nf-bam2fastq: Simple BAM to FASTQ Nextflow pipeline
 *
 * Copyright (C) 2019 QIMR Berghofer Medical Research Institute
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */


nextflow.preview.dsl=2


import nextflow.splitter.CsvSplitter
import nextflow.config.ConfigParser

nextflow_config = file("${baseDir}/nextflow.config").text
parsed_config = new ConfigParser().setIgnoreIncludes(true).parse(nextflow_config)
defaults = parsed_config.params

check_params()



/*
 * Log workflow options
 */

// Nextflow exectution options
log.info("Config profile: ${workflow.profile}")
log.info("Workflow revision: ${workflow.revision}")
log.info("Workflow work-dir: ${workflow.workDir}")

// Input options
log.info("Input BAM paths: ${params.bams}")

// Output options
log.info("Output directory: ${params.outdir}")
log.info("Format string: \"${params.format_string}\"")
log.info("Compression level: ${params.compression_level}")



/*
 * Log advanced options
 */

// Reports options
log.info("Execution report: ${params.execution_report}")
log.info("Trace report: ${params.trace_report}")
log.info("Timeline report: ${params.timeline_report}")
log.info("Flowchart: ${params.flowchart}")

// AWS Batch options
log.info("AWS Batch JobQueue: ${params.aws_queue}")
log.info("AWS Region: ${params.aws_region}")



/*
 * Processes
 */

process split {

    tag { bam }

    label 'samtools'

    input:
    path bam

    output:
    path "*.bam"

    """
    samtools split \\
        -f "${params.format_string}" \\
        -u "${bam.getBaseName()}.unaccounted.bam" \\
        "${bam}"
    """
}


process fastq {

    tag { bam }

    label 'samtools'

    input:
    path bam

    output:
    path "*.fastq.gz"

    """
    samtools collate -Ou "${bam}" "${bam.getBaseName()}" | samtools fastq \\
        -c "${params.compression_level}" \\
        -n \\
        -F 256 -F 512 -F 2048 \\
        -0 "${bam.getBaseName()}.0.fastq.gz" \\
        -1 "${bam.getBaseName()}.1.fastq.gz" \\
        -2 "${bam.getBaseName()}.2.fastq.gz" \\
        -s "${bam.getBaseName()}.s.fastq.gz"
    """
}



/*
 * Workflows
 */

workflow {

    main:
    Channel.fromPath( params.bams, checkIfExists: true ) \
        | split \
        | flatten \
        | fastq

    publish:
    fastq.out to: params.outdir, mode: 'copy'
}


workflow.onComplete {

    log.info "Workflow completed at: ${workflow.complete}"
    log.info "Time taken: ${workflow.duration}"
    log.info "Execution status: ${workflow.success ? 'success' : 'failed'}"
    log.info "Output directory: ${params.outdir}"
}


workflow.onError {

    log.info "Execution halted: ${workflow.errorMessage}"
}



/*
 * Functions
 */

def usage() {

    log.info"""
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
            Path where the results will be saved [Default: ${defaults.outdir}]

        --format_string STR
            Output file format string [Default: "${defaults.format_string}"]

            Format string expansions:
              %%     %
              %*     basename
              %#     @RG index
              %!     @RG ID
              %.     filename extension for output format

        --compression_level INT
            Output file compression level [Default: ${defaults.compression_level}]


    Standard options:

        --advanced
            Show advanced usage and exit

        --help
            Show this message and exit

        --version
            Show the pipeline version and exit
    """.stripIndent()
}

def advanced() {

    log.info"""
    Report options:

        --execution_report STR
            Name of the Nextflow execution report to generate [Default: ${defaults.execution_report}]

        --trace_report STR
            Name of the Nextflow trace report to generate [Default: ${defaults.trace_report}]

        --timeline_report STR
            Name of the Nextflow timeline report to generate [Default: ${defaults.timeline_report}]

        --flowchart STR
            Name of the Nextflow flowchart to generate [Default: ${defaults.flowchart}]


    AWS Batch options:

        --aws_queue STR
            AWS Batch JobQueue definition [Default: ${defaults.aws_queue}]

        --aws_region STR
            AWS Region definition [Default: ${defaults.aws_region}]
    """.stripIndent()
}

def die() {
    usage()
    exit 1
}

def check_params() {

    // Standard options

    if (params.advanced) {
        advanced()
        exit 0
    }

    if (params.help) {
        usage()
        exit 0
    }

    if (params.version) {
        log.info(workflow.manifest.version)
        exit 0
    }


    // Input options

    if (!params.bams) {
        log.error("No BAM files specified. Please use the `--bams` option.")
        die()
    }


    // Output options

    if (!(params.compression_level.toString().isInteger())) {
        log.error("Unknown `--compression_level` entry: `${params.compression_level}`")
        die()
    }

    if (!(params.compression_level >= 1 && params.compression_level <= 9)) {
        log.error("The value specified using `--compression_level` must be in the range 1..9")
        die()
    }


    // Report options

    if (!params.execution_report.toString().endsWith('.html')) {
        log.error("The filename specified using `--execution_report` must end with '.html'")
        die()
    }

    if (!params.trace_report.toString().endsWith('.txt')) {
        log.error("The filename specified using `--trace_report` must end with '.txt'")
        die()
    }

    if (!params.timeline_report.toString().endsWith('.html')) {
        log.error("The filename specified using `--timeline_report` must end with '.html'")
        die()
    }

    def flowchart_extns = ['.dot', '.html', '.pdf', '.png', '.svg']

    if (!(flowchart_extns.any { params.flowchart.toString().endsWith(it) })) {
        log.error("The filename specified using `--flowchart` must end with one of ${flowchart_extns.join(", ")}")
        die()
    }
}
