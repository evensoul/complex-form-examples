require File.expand_path('../../test_helper', __FILE__)

describe "On a ProjectsController, when updating", ActionController::TestCase do
  tests ProjectsController
  
  before do
    @project = Project.create(:name => 'NestedParams')
    @project.create_author(:name => 'Eloy')
    @task1 = @project.tasks.create(:name => 'Check other implementations')
    @project.tasks.create(:name => 'Try with our plugin')
    
    @task1.colors.create(:name => 'Blue')
    @task1.colors.create(:name => 'Purple')
    
    @tasks = @project.tasks
    @colors = @task1.colors
    
    @valid_update_params = {:name => 'Dinner', :tasks_attributes => [
      { :id => @tasks.first.id, :name => "Buy food", :colors_attributes => [
        { :id => @colors.first.id, :name => "Green" },
        { :id => @colors.last.id, :name => "Orange" },        
      ]},
      { :id => @tasks.last.id,  :name => "Cook" }
    ]}
  end
  
  it "should update the name of the author" do
    put :update, :id => @project.id, :project => { :author_attributes => { :name => 'Mighty Mo' }}
    @project.reload.author.name.should == 'Mighty Mo'
  end
  
  it "should update attributes of the nested tasks and colors" do
    put :update, :id => @project.id, :project => @valid_update_params
    @project.reload
    
    @project.name.should == 'Dinner'
    @project.tasks.map(&:name).sort.should == ['Buy food', 'Cook']
    @project.tasks.first.colors.map(&:name).sort.should == ['Green', 'Orange']
  end
  
  it "should destroy a missing task" do
    @valid_update_params[:tasks_attributes].first['_delete'] = '1'
    
    lambda {
      put :update, :id => @project.id, :project => @valid_update_params
    }.should.differ('Task.count', -1)
  end
  
  it "should add a new task" do
    @valid_update_params[:tasks_attributes] << { :name => 'Take out' }
    
    lambda {
      put :update, :id => @project.id, :project => @valid_update_params
    }.should.differ('Task.count', +1)
  end
  
  
  it "should add a new color for second task" do
    @valid_update_params[:tasks_attributes][1].merge!({
      :colors_attributes => [
        {:name => 'Red'}
      ]       
    })    
        
    lambda {
      put :update, :id => @project.id, :project => @valid_update_params
    }.should.differ('Color.count', +1)
  end
  
  it "should reject any new task where the name is empty" do
    @valid_update_params[:tasks_attributes] << { 'name' => '', :due_at => nil }
    
    lambda {
      put :update, :id => @project.id, :project => @valid_update_params
    }.should.not.differ('Task.count')
    
    assigns(:project).should.be.valid
  end
  
   it "should reject any new color where the name is empty" do
    @valid_update_params[:tasks_attributes][0][:colors_attributes] << { 'name' => ''}
    
    lambda {
      put :update, :id => @project.id, :project => @valid_update_params
    }.should.not.differ('Color.count')
    
    assigns(:project).should.be.valid
  end
  
  it "should destroy a task and add a new one" do
    @valid_update_params[:tasks_attributes].first['_delete'] = '1'
    @valid_update_params[:tasks_attributes] << { :name => 'Take out' }
    
    lambda {
      put :update, :id => @project.id, :project => @valid_update_params
    }.should.not.differ('Task.count')
  end
  
  
  it "should destroy a color and add a new one" do
    @valid_update_params[:tasks_attributes][0][:colors_attributes].first['_delete'] = '1'
    @valid_update_params[:tasks_attributes][0][:colors_attributes] << { :name => 'Yellow' }
    
    lambda {
      put :update, :id => @project.id, :project => @valid_update_params
    }.should.not.differ('Color.count')
    
    @project.tasks.first.colors.map(&:name).sort.should == ['Orange', 'Yellow']
  end
  
  
  it "should destroy first task colors if task is destroyed" do
    @valid_update_params[:tasks_attributes].first['_delete'] = '1'    
    
    lambda {
      put :update, :id => @project.id, :project => @valid_update_params
    }.should.differ('Color.count', -2)
  end
  
  it "should not be valid if a task is invalid" do
    put :update, :id => @project.id, :project => { :name => 'Nothing', :tasks_attributes =>[
      { :id => @tasks.first.id, :name => '' },
      { :id => @tasks.last.id, :name => '' }
    ]}
    
    project = assigns(:project)
    
    project.should.not.be.valid
    project.errors.on(:tasks_name).should == "can't be blank"
    
    project.reload
    project.name.should == 'NestedParams'
  end
  
  
   it "should not be valid if a color is invalid" do
    put :update, :id => @project.id, :project => { :name => 'Nothing', :tasks_attributes =>[
      { :id => @tasks.first.id, :name => 'Eat cooked food', :colors_attributes =>[
        {:id=>@colors.first.id, :name => ''},
        {:id=>@colors.last.id, :name => ''}
      ]}     
    ]}
    
    project = assigns(:project)
    
    project.should.not.be.valid
    project.errors.on(:tasks_colors_name).should == "can't be blank"
    
    project.reload
    project.name.should == 'NestedParams'
  end
end
