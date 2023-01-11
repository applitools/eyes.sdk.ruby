# frozen_string_literal: true

RSpec.describe 'Eyes send dom flag' do
  let(:send_dom_target) { Applitools::Selenium::Target.window.send_dom }
  let(:do_not_set_dom_target) { Applitools::Selenium::Target.window.send_dom(false) }
  let(:common_target) { Applitools::Selenium::Target.window }
  context Applitools::Selenium::SeleniumEyes do
    it 'default value should be true' do
      expect(subject.send_dom).to be_truthy
    end
    it 'eyes.send_dom = true value should send dom' do
      subject.send_dom = true
      expect(subject.send(:send_dom?, common_target)).to be_truthy
    end
    it 'eyes.send_dom = false value should not send dom' do
      subject.send_dom = false
      expect(subject.send(:send_dom?, common_target)).to be_falsey
    end
    context 'Target takes a precedence' do
      context 'eyes.send_dom = false' do
        before do
          subject.send_dom = false
        end
        it 'when true' do
          expect(subject.send(:send_dom?, send_dom_target)).to be_truthy
        end
        it 'when false' do
          expect(subject.send(:send_dom?, do_not_set_dom_target)).to be_falsey
        end
      end
      context 'eyes.send_dom = true' do
        before do
          subject.send_dom = true
        end
        it 'when true' do
          expect(subject.send(:send_dom?, send_dom_target)).to be_truthy
        end
        it 'when false' do
          expect(subject.send(:send_dom?, do_not_set_dom_target)).to be_falsey
        end
      end
    end
  end
end
