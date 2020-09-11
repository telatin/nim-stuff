set -e
true
/Users/telatina/miniconda3/bin/spades-hammer /Users/telatina/git/nim-stuff/orf/assembly/corrected/configs/config.info
/Users/telatina/miniconda3/bin/python /Users/telatina/miniconda3/share/spades/spades_pipeline/scripts/compress_all.py --input_file /Users/telatina/git/nim-stuff/orf/assembly/corrected/corrected.yaml --ext_python_modules_home /Users/telatina/miniconda3/share/spades --max_threads 16 --output_dir /Users/telatina/git/nim-stuff/orf/assembly/corrected --gzip_output
true
true
/Users/telatina/miniconda3/bin/spades-core /Users/telatina/git/nim-stuff/orf/assembly/K21/configs/config.info
/Users/telatina/miniconda3/bin/spades-core /Users/telatina/git/nim-stuff/orf/assembly/K33/configs/config.info
/Users/telatina/miniconda3/bin/spades-core /Users/telatina/git/nim-stuff/orf/assembly/K55/configs/config.info
/Users/telatina/miniconda3/bin/spades-core /Users/telatina/git/nim-stuff/orf/assembly/K77/configs/config.info
/Users/telatina/miniconda3/bin/spades-core /Users/telatina/git/nim-stuff/orf/assembly/K99/configs/config.info
/Users/telatina/miniconda3/bin/spades-core /Users/telatina/git/nim-stuff/orf/assembly/K127/configs/config.info
/Users/telatina/miniconda3/bin/python /Users/telatina/miniconda3/share/spades/spades_pipeline/scripts/copy_files.py /Users/telatina/git/nim-stuff/orf/assembly/K127/before_rr.fasta /Users/telatina/git/nim-stuff/orf/assembly/before_rr.fasta /Users/telatina/git/nim-stuff/orf/assembly/K127/final_contigs.fasta /Users/telatina/git/nim-stuff/orf/assembly/contigs.fasta /Users/telatina/git/nim-stuff/orf/assembly/K127/first_pe_contigs.fasta /Users/telatina/git/nim-stuff/orf/assembly/first_pe_contigs.fasta /Users/telatina/git/nim-stuff/orf/assembly/K127/scaffolds.fasta /Users/telatina/git/nim-stuff/orf/assembly/scaffolds.fasta /Users/telatina/git/nim-stuff/orf/assembly/K127/scaffolds.paths /Users/telatina/git/nim-stuff/orf/assembly/scaffolds.paths /Users/telatina/git/nim-stuff/orf/assembly/K127/assembly_graph_with_scaffolds.gfa /Users/telatina/git/nim-stuff/orf/assembly/assembly_graph_with_scaffolds.gfa /Users/telatina/git/nim-stuff/orf/assembly/K127/assembly_graph.fastg /Users/telatina/git/nim-stuff/orf/assembly/assembly_graph.fastg /Users/telatina/git/nim-stuff/orf/assembly/K127/final_contigs.paths /Users/telatina/git/nim-stuff/orf/assembly/contigs.paths
true
/Users/telatina/miniconda3/bin/python /Users/telatina/miniconda3/share/spades/spades_pipeline/scripts/breaking_scaffolds_script.py --result_scaffolds_filename /Users/telatina/git/nim-stuff/orf/assembly/scaffolds.fasta --misc_dir /Users/telatina/git/nim-stuff/orf/assembly/misc --threshold_for_breaking_scaffolds 3
true
