require 'openssl'
require 'securerandom'
require 'rbconfig'
require 'tempfile'
require 'azure/storage/blob'
require_relative 'params'
require_relative 'log/log'

begin
  # Params
  params = Params.new
  params.print
  params.validate

  if params.container.to_s.empty? || params.account_name.to_s.empty?|| params.account_key.to_s.empty? || params.object.to_s.empty?  || params.filename.to_s.empty? 
    raise 'Error: Not all fields set cannot proceed!'
  end

  file = File.open(params.filename, "r")

  # Create a BlobService object
  blob_client = Azure::Storage::Blob::BlobService.create(
      storage_account_name: params.account_name,
      storage_access_key: params.account_key
  )

  blob_client.set_container_acl(params.container, "container")

  blob_client.create_block_blob(params.container, params.object.dup, file)

rescue => ex
  puts
  Log.error('Error:')
  Log.error(ex.to_s)
  puts
  Log.error('Stacktrace (for debugging):')
  Log.error(ex.backtrace.join("\n").to_s)
  exit 1
end
