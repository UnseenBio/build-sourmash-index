# Build a Sourmash Database for Fast Search

Build a database of sourmash signatures from a genomic library.

## Usage

1. Set up nextflow as [described
   here](https://www.nextflow.io/index.html#GetStarted).
2. If you didn't run this pipeline in a while, possibly update nextflow itself.

   ```sh
   nextflow self-update
   ```

3. Then run the pipeline.

   1. Sequence Bloom Tree (SBT) indexed databases

      ```sh
      nextflow run main.nf --input 'genomes/*.fna'
      ```
   
      We suggest that you make use of one of the provided profiles that enhance reproducibility, i.e., `-profile docker|singularity|conda`.
   
      In this form, the pipeline will generate an SBT index, by default, this results in a `.sbt.zip` file.

   2. Reverse indexed (LCA) databases

      Alternatively, you can provide a taxonomy table similar to the one [shown here](https://sourmash.readthedocs.io/en/latest/sourmash-collections.html#build-a-database-with-taxonomic-information---) and invoke the nextflow pipeline with the taxonomy information.

      ```sh
      nextflow run main.nf --input 'genomes/*.fna' --taxonomy 'podar-lineage.csv'
      ```

      This will result in an index `.lca.json.gz` file.


## Copyright

* Copyright © 2022 Unseen Bio ApS.
* Free software distributed under the [GNU Affero General Public License version 3 or later (AGPL-3.0-or-later)](https://opensource.org/licenses/AGPL-3.0).
