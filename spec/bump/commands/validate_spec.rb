require "spec_helper"

describe Bump::CLI::Commands::Validate do
  it "calls the server and exit successfully if success" do
    stub_bump_api_validate("validations/post_success.http")

    expect {
      new_command.call(
        doc: "aaaa0000-bb11-cc22-dd33-eeeeee444444",
        "doc-name": "Hello world",
        hub: "aaaa0000-bb11-cc22-dd33-eeeeee444444",
        token: "token",
        file: "path/to/file",
        specification: "api-blueprint/v1a9",
        validation: "strict",
        "auto-create": true
)
    }.to output(/Definition is valid/).to_stdout

    expect(WebMock).to have_requested(:post, "https://bump.sh/api/v1/validations").with(
      body: {
        documentation_id: "aaaa0000-bb11-cc22-dd33-eeeeee444444",
        documentation_name: "Hello world",
        hub_id: "aaaa0000-bb11-cc22-dd33-eeeeee444444",
        definition: "body",
        references: [],
        specification: "api-blueprint/v1a9",
        validation: "strict",
        auto_create_documentation: true
      }
    )
  end

  it "validates with slugs instead of ids" do
    stub_bump_api_validate("validations/post_success.http")

    expect {
      new_command.call(
        doc: "documentation-slug",
        hub: "hub-slug",
        file: "path/to/file"
      )
    }.to output(/Definition is valid/).to_stdout

    expect(WebMock).to have_requested(:post, "https://bump.sh/api/v1/validations").with(
      body: hash_including(
        documentation_slug: "documentation-slug",
        hub_slug: "hub-slug"
      )
    )
  end

  it "supports deprecated id option and displays a warning" do
    stub_bump_api_validate("validations/post_success.http")

    expect {
      new_command.call(
        id: "old-school-id",
        file: "path/to/file"
      )
    }.to output(/[DEPRCATION WG]/).to_stdout

    expect(WebMock).to have_requested(:post, "https://bump.sh/api/v1/validations").with(
      body: hash_including(
        documentation_id: "old-school-id"
      )
    )
  end

  it "displays the definition errors in case of unprocessable entity" do
    stub_bump_api_validate("validations/post_unprocessable_entity.http")

    expect {
      begin
        new_command.call(doc: "1", token: "token", file: "path/to/file", specification: "openapi/v2/yaml", validation: "basic")
      rescue SystemExit; end
    }.to output(/Invalid request/).to_stderr
  end

  it "displays a generic error message in case of unknown error" do
    stub_bump_api_validate("validations/post_unknown_error.http")

    expect {
      begin
        new_command.call(doc: "1", token: "token", file: "path/to/file", specification: "openapi/v2/yaml", validation: "basic")
      rescue SystemExit; end
    }.to output(/Unknown error/).to_stderr
  end

  private

  def stub_bump_api_validate(path)
    stub_request(:post, %r{/validations}).to_return(read_http_fixture(path))
  end

  def new_command
    command = Bump::CLI::Commands::Validate.new
    allow(Bump::CLI::Resource).to receive(:read).and_return("body")
    command
  end
end
