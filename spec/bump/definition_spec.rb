require "spec_helper"

describe Bump::CLI::Definition do
  describe "#prepare" do
    it "opens the file and reads its content" do
      definition = Bump::CLI::Definition.new("path/to/file")
      allow(Bump::CLI::Resource).to receive(:read).and_return("content")

      definition.prepare!

      expect(definition.content).to eq("content")
    end

    it "loads the definition and import references" do
      definition = Bump::CLI::Definition.new("path/to/file", import_external_references: true)
      allow(Bump::CLI::Resource).to receive(:read).and_return("property: value")
      allow(definition.external_references).to receive(:load).and_call_original

      definition.prepare!

      expect(definition.content).to eq("property: value")
      expect(definition.external_references).to have_received(:load).with("property" => "value")
    end

    it "loads YAML definition and serializes it correctly" do
      definition = Bump::CLI::Definition.new("path/to/file", import_external_references: true)
      allow(Bump::CLI::Resource).to receive(:read).and_return("property: value")

      definition.prepare!

      expect(definition.content).to include("property: value")
    end

    it "loads JSON definition" do
      definition = Bump::CLI::Definition.new("path/to/file", import_external_references: true)
      allow(Bump::CLI::Resource).to receive(:read).and_return("{\"property\": \"value\"}")

      definition.prepare!

      expect(definition.content).to include("{\"property\": \"value\"}")
    end
  end
end
