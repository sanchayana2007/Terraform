import apache_beam as beam

def my_grep(line, term):
   if line.startswith(term):
      yield line

PROJECT='seismic-elf-261104'
BUCKET=''

def run():
   argv = [
      '--project=\"seismic-elf-261104\"',
      '--job_name=\"examplejob2\"',
      '--save_main_session',
      '--temp_location = \"gs://seismic-elf-261104.sanch-test-bucket/tmp/\"',
      '--staging_location = gs://seismic-elf-261104.sanch-test-bucket/stg/\"',
      '--_location = \"US\"',
      '--region=\"us-central1-a\"',
      '--runner=\"DataflowRunner\"'
   ]

   p = beam.Pipeline(argv=argv)
   input = 'gs://seismic-elf-261104.sanch-test-bucket/*.py'
   output_prefix = 'gs://seismic-elf-261104.sanch-test-bucket/tmp'
   searchTerm = 'import'

   # find all lines that contain the searchTerm
   (p
      | 'GetJava' >> beam.io.ReadFromText(input)
      | 'Grep' >> beam.FlatMap(lambda line: my_grep(line, searchTerm) )
      | 'write' >> beam.io.WriteToText(output_prefix)
   )

   p.run()

if __name__ == '__main__':
   run()
