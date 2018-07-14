require 'rails_helper'

describe Message, type: :model do
  SHORT_TYPE = Message::SHORT_TYPE.freeze
  REGULAR_TYPE = Message::REGULAR_TYPE.freeze
  PAYLOAD_RANGES = Message::PAYLOAD_RANGES.freeze
  MESSAGE_TYPES = Message::MESSAGE_TYPES.freeze

  def gen_string(len)
    (0...len).map { (65 + rand(26)).chr }.join
  end

  shared_examples_for 'length restricted payload' do
    it { is_expected.not_to allow_value(below_min_len_str).for(:payload) }
    it { is_expected.not_to allow_value(above_max_len_str).for(:payload) }
    it { is_expected.to allow_value(border_min_len_str).for(:payload) }
    it { is_expected.to allow_value(border_max_len_str).for(:payload) }
  end

  shared_examples_for 'checking payload size' do |type|
    context "when `message_type` is #{type}" do
      subject { described_class.new(message_type: type, payload: payload) }

      context 'and `payload` is in range' do
        let(:payload) { gen_string(PAYLOAD_RANGES[type].first) }
        it { expect(subject.send(:payload_out_of_range?)).to be false }
      end

      context 'and `payload` is out of range' do
        let(:payload) { gen_string(PAYLOAD_RANGES[type].last + 1) }
        it { expect(subject.send(:payload_out_of_range?)).to be true }
      end

      context 'and `payload` is  `nil`' do
        let(:payload) { nil }
        it { expect(subject.send(:payload_out_of_range?)).to be false }
      end
    end
  end

  describe 'validations' do
    it { should validate_presence_of(:message_type) }
    it { should define_enum_for(:message_type).with(MESSAGE_TYPES) }
    it { should validate_presence_of(:payload) }

    describe 'payload validations' do
      let(:below_min_len_str) { gen_string(min_len - 1) }
      let(:above_max_len_str) { gen_string(max_len + 1) }
      let(:border_min_len_str) { gen_string(min_len) }
      let(:border_max_len_str) { gen_string(max_len) }
      let(:containing_digit) { gen_string((min_len+max_len)/2) + '1' }

      context "when `message_type` is `#{SHORT_TYPE}`" do
        subject { described_class.new(message_type: SHORT_TYPE) }
        let(:min_len) { PAYLOAD_RANGES[SHORT_TYPE][0] }
        let(:max_len) { PAYLOAD_RANGES[SHORT_TYPE][1] }

        it_behaves_like 'length restricted payload'

        context 'and `payload` contains a digit' do
          it { is_expected.not_to allow_value(containing_digit).for(:payload) }
        end
      end

      context "when `message_type` is `#{REGULAR_TYPE}`" do
        subject { described_class.new(message_type: 'text') }
        let(:min_len) { PAYLOAD_RANGES[REGULAR_TYPE][0] }
        let(:max_len) { PAYLOAD_RANGES[REGULAR_TYPE][1] }

        it_behaves_like 'length restricted payload'

        context 'and `payload` contains a digit' do
          it { is_expected.to allow_value(containing_digit).for(:payload) }
        end
      end
    end
  end

  describe '#payload_length' do
    context 'when invalid length' do
      subject { described_class.new(message_type: SHORT_TYPE, payload: 'a') }

      it 'contains an error message' do
        subject.valid?
        expect(subject.errors.messages[:payload].present?)
      end
    end
  end

  describe '#payload_range' do
    subject { described_class.new(message_type: type, payload: 'payload') }

    context "when `message_type` is `#{SHORT_TYPE}`" do
      let(:type) { SHORT_TYPE }

      it "returns #{PAYLOAD_RANGES[SHORT_TYPE]}" do
        expect(subject.send(:payload_range)).to eq PAYLOAD_RANGES[SHORT_TYPE]
      end
    end

    context "when `message_type` is `#{REGULAR_TYPE}`" do
      let(:type) { REGULAR_TYPE }

      it "returns #{PAYLOAD_RANGES[REGULAR_TYPE]}" do
        expect(subject.send(:payload_range)).to eq PAYLOAD_RANGES[REGULAR_TYPE]
      end
    end
  end

  describe '#payload_out_of_range?' do
    it_behaves_like 'checking payload size', SHORT_TYPE
    it_behaves_like 'checking payload size', REGULAR_TYPE
  end

  describe '#payload_no_digits' do
    context 'when payload with a digit' do
      subject { described_class.new(message_type: SHORT_TYPE, payload: 'asd1f') }

      it 'contains an error message' do
        subject.valid?
        expect(subject.errors.messages[:payload].present?)
      end
    end
  end

  describe '#payload_with_digits' do
    context 'when `payload` is `nil`' do
      subject { described_class.new(message_type: SHORT_TYPE, payload: nil) }

      it 'returns `false`' do
        expect(subject.send(:payload_with_digits?)).to be false
      end
    end

    context 'when `payload` is alphabet characters only' do
      subject { described_class.new(message_type: SHORT_TYPE, payload: 'asd') }

      it 'returns `false`' do
        expect(subject.send(:payload_with_digits?)).to be false
      end
    end

    context 'when `payload` contains a digit' do
      subject { described_class.new(message_type: SHORT_TYPE, payload: 'as1d') }

      it 'returns `true`' do
        expect(subject.send(:payload_with_digits?)).to be true
      end
    end
  end
end
