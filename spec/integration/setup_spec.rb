require 'spec_helper'

describe 'Setting up ROM' do
  context 'with existing schema' do
    include_context 'users and tasks'

    let(:jane) { { name: 'Jane', email: 'jane@doe.org' } }
    let(:joe) { { name: 'Joe', email: 'joe@doe.org' } }

    it 'configures relations' do
      expect(rom.memory.users).to match_array([joe, jane])
    end

    it 'raises on double-finalize' do
      expect {
        2.times { setup.finalize }
      }.to raise_error(ROM::EnvAlreadyFinalizedError)
    end
  end

  context 'without schema' do
    it 'builds empty registries if there is no schema' do
      setup = ROM.setup(memory: 'memory://test')

      setup.relation(:users)

      rom = setup.finalize

      expect(rom.relations).to eql(ROM::RelationRegistry.new)
      expect(rom.mappers).to eql(ROM::ReaderRegistry.new)
    end
  end

  describe 'quick setup' do
    it 'exposes boot DSL inside the setup block' do
      User = Class.new { include Virtus.value_object; values { attribute :name, String } }

      rom = ROM.setup(memory: 'memory://test') do
        schema do
          base_relation(:users) do
            repository :memory
            attribute :name
          end
        end

        relation(:users) do
          def by_name(name)
            restrict(name: name)
          end
        end

        commands(:users) do
          define(:create)
        end

        mappers do
          define(:users) do
            model User
          end
        end
      end

      rom.command(:users).create.call(name: 'Jane')

      expect(rom.read(:users).by_name('Jane').to_a).to eql([User.new(name: 'Jane')])
    end
  end
end
