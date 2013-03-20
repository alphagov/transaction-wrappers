EPDQ.accounts = {
  'legalisation-post' => EPDQ::Account.new(
    :pspid => ENV["epdq_legalisation_pspid"] || 'pspid',
    :sha_type => :sha1,
    :sha_in => ENV["epdq_legalisation_post_sha_in"] || "00000000000000000000000000000000000000000",
    :sha_out => ENV["epdq_legalisation_post_sha_out"] || "00000000000000000000000000000000000000000",
    :test_mode => true
  ),
  'legalisation-drop-off' => EPDQ::Account.new(
    :pspid => ENV["epdq_pspid"] || 'pspid',
    :sha_type => :sha1,
    :sha_in => ENV["epdq_legalisation_dropoff_sha_in"] || "00000000000000000000000000000000000000000",
    :sha_out => ENV["epdq_legalisation_dropoff_sha_out"] || "00000000000000000000000000000000000000000",
    :test_mode => true
  ),
  'birth-death-marriage' => EPDQ::Account.new(
    :pspid => ENV["epdq_birth_pspid"] || 'pspid',
    :sha_type => :sha1,
    :sha_in => ENV["epdq_birth_sha_in"] || "00000000000000000000000000000000000000000",
    :sha_out => ENV["epdq_birth_sha_out"] || "00000000000000000000000000000000000000000",
    :test_mode => true
  )
}
