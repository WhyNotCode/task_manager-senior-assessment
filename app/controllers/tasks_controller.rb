# Tasks Controller
# =========================
# Manages CRUD operations for tasks in the Task Manager application.
# Supports listing, creating, updating, deleting, and toggling completion status of tasks.
# Utilizes strong parameters for security and handles responses in both HTML and JSON formats.  

# Assumptions:
# - Task model exists with attributes: title, description, completed_at (datetime)
# - Routes are set up for standard RESTful actions plus a custom action for toggling completion status.
# =================================================================================

class TasksController < ApplicationController
  before_action :set_task, only: [:show, :edit, :update, :destroy, :toggle_complete]


  # GET /tasks or /tasks.json
  def index
    @tasks = Task.all.order(created_at: :desc)
    @completed_tasks = Task.completed.order(completed_at: :desc)
    @incomplete_tasks = Task.incomplete.order(created_at: :desc)
    @task = Task.new
  end
  
  # GET /tasks/1 or /tasks/1.json
  def show
  end

  # GET /tasks/new
  def new
    @task = Task.new
  end

  # GET /tasks/1/edit
  def edit
  end

  # POST /tasks or /tasks.json
  def create
    @task = Task.new(task_params)

    respond_to do |format|
      if @task.save
        format.html { redirect_to @task, notice: "Task was successfully created." }
        format.json { render :show, status: :created, location: @task }
      else
        format.html { flash.now[:alert] = "Could not create task. Please check the errors below."
                      render :new, status: :unprocessable_entity }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tasks/1 or /tasks/1.json
  def update
    respond_to do |format|
      if @task.update(task_params)
        format.html { redirect_to @task, notice: "Task '#{@task.title}' was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @task }
      else
        format.html { flash.now[:alert] = "Could not update task. Please check the errors below."
                      render :edit, status: :unprocessable_entity }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /task/1 or /task/1.json
  # def complete
  #   respond_to do |format|
  #     if @task.complete(true)
  #       format.html { redirect_to @task, notice: "Task was successfully updated.", status: :see_other }
  #       format.json { render :show, status: :ok, location: @task }
  #     end
  #   end
  # end

  def toggle_complete
    if @task.completed?
      @task.incomplete!
      notice_message = "Task '#{@task.title}' marked as incomplete."
    else
      @task.complete!
      notice_message = "Task '#{@task.title}' marked as complete."
    end
    
    respond_to do |format|
      format.html { redirect_to tasks_path, notice: notice_message }
    end
  end


  # DELETE /tasks/1 or /tasks/1.json
  def destroy
    task_title = @task.title
    
    begin
      @task.destroy!
      flash[:notice] = "Task '#{task_title}' was successfully destroyed."
    rescue => e
      flash[:alert] = "Could not delete task: #{e.message}"
    end

    respond_to do |format|
      format.html { redirect_to tasks_path, status: :see_other }
      format.json { head :no_content }
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_task
      @task = Task.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def task_params
      params.require(:task).permit(:title, :description, :completed)
    end
end
