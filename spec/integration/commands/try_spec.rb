require 'spec_helper'

describe 'Commands / Try api' do
  include_context 'users and tasks'

  before do
    setup.relation(:users)

    setup.commands(:users) do
      define(:create) do
        input Hash
        validator Proc.new {}
      end
    end
  end

  let(:user_commands) { rom.command(:users) }

  it 'exposes command functions inside the block' do
    input = { name: 'Piotr', email: 'piotr@test.com' }

    result = user_commands.try { create(input) }

    expect(result.value).to eql([input])
  end

  it 'raises on method missing' do
    expect { users.try { not_here } }.to raise_error(NameError)
  end
end