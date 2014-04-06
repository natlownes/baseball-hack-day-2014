expect = require('chai').expect
{
  YearSelect
} = require '../src/index'


describe 'YearSelect view', ->

  it 'should render the year range', ->
    view = new YearSelect
    view.render()
    expect(view.$el.html()).to.include """
    <option value="1999">1999</option>
    """
    expect(view.$el.html()).to.include """
    <option value="2011">2011</option>
    """

  describe '#selectedYear', ->

    it 'should return the year', ->
      view = new YearSelect
      view.render()
      view.$('option[value=1999]').prop('selected', true)

      expect(view.selectedYear()).to.equal '1999'



