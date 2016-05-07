module Keychain

  def self.find(name:, kind:)
    candidate = Keychain::Entry.new name: name, kind: kind
    candidate if candidate.exists?
  end

end
