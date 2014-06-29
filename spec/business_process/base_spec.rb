require 'spec_helper'
require 'business_process/base'

class BusinessProcessSubclassFactory
  def self.get(*requirements)
    Class.new(BusinessProcess::Base).tap do |klass|
      requirements.each { |requirement| klass.needs requirement }
      klass.send(:define_method, :call, -> { requirements.map { |requirement| self.send(requirement) } })
    end
  end
end

describe BusinessProcess::Base do
  let(:klass) { BusinessProcessSubclassFactory.get(*requirements) }
  let(:requirements) { [] }
  let(:attribute_object) { double }

  describe '.call' do
    let(:perform) { klass.call(attribute_object) }

    it { expect(perform).to be_kind_of BusinessProcess::Base }

    context 'parameter is required' do
      let(:requirements) { [:some_method] }

      context 'attribute object does not provide method' do
        it { expect { perform }.to raise_error NoMethodError }
      end

      context 'attribute object does provide method' do
        let(:attribute_object) { double(some_method: 10) }

        it { expect { perform }.not_to raise_error }
      end

      context 'attribute object is a hash' do
        let(:attribute_object) { {} }

        context 'attribute object does not provide parameter key' do
          it { expect { perform }.to raise_error NoMethodError }
        end

        context 'attribute object does  provide parameter key' do
          let(:attribute_object) { {some_method: 10} }

          it { expect { perform }.not_to raise_error }
        end
      end
    end
  end

  describe '#result' do
    let!(:instance) { klass.call(attribute_object) }

    context 'some attributes are provided' do
      let(:requirements) { [:some_method, :some_other_method] }
      let(:attribute_object) { double(some_method: 10, some_other_method: 20) }

      it 'stores result of execution of #call method in result accessor' do
        expect(instance.result).to eq [10, 20]
      end

      context 'attribute object is a hash' do
        let(:attribute_object) { {some_method: 10, some_other_method: 20} }

        it 'stores result of execution of #call method in result accessor' do
          expect(instance.result).to eq [10, 20]
        end
      end
    end
  end

  describe '#success!' do
    let(:instance) { klass.call(double) }

    context '#call returns false' do
      before { klass.send(:define_method, :call, -> { false }) }

      it { expect(instance.success?).to be_falsey }
    end

    context '#call returns true' do
      before { klass.send(:define_method, :call, -> { true }) }

      it { expect(instance.success?).to be_truthy }
    end
  end


  describe '#valid?' do
    let(:instance) { klass.new(attribute_object) }

    context 'parameter is required' do
      let(:requirements) { [:some_method] }

      context 'attribute object does not provide method' do
        it { expect(instance.valid?).to be_falsey }
      end

      context 'attribute object does provide method' do
        let(:attribute_object) { double(some_method: 10) }

        it { expect(instance.valid?).to be_truthy }
      end
    end
  end
end
