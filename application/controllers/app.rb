# frozen_string_literal: true

require 'roda'
require 'slim'
require 'slim/include'


module ThxSeafood
  # Web App
  class App < Roda
    plugin :render, engine: 'slim', views: 'presentation/views'
    # plugin :render, views: 'presentation/views'
    plugin :assets, css: 'style.css', path: 'presentation/assets'
    plugin :flash
    use Rack::Session::Cookie, secret: config.SESSION_SECRET

    route do |routing|
      routing.assets
      app = App

      # GET / request
      routing.root do
        jobs_json = ApiGateway.new.all_jobs.message   # String
        all_jobs = ThxSeafood::JobsRepresenter.new(OpenStruct.new).from_json jobs_json
        all_jobs_json = ThxSeafood::JobsRepresenter.new(all_jobs).to_json   # String

        # projects = Views::AllProjects.new(all_jobs)
        projects = Views::JsonAllProjects.new(all_jobs_json)
        if projects.none?
          flash.now[:error] = 'No data in databse.'
        end
        if projects.any?
          flash.now[:notice] = 'Data is showing below'
        end
        view 'jobmap', locals: { projects: projects }
        # view 'ThxSeafood', locals: { projects: projects }
        # view 'home', locals: { jobs_json: jobs_json }
      end


      routing.on 'jobs' do
        # routing.is do
        #   routing.post do            
        #     result = AddProject.new.call(query: routing.params)

        #     if result.success?
        #       flash[:notice] = 'New project added!'
        #     else
        #       flash[:error] = result.value
        #     end

        #     routing.redirect "/#{routing.params}"
        #   end
        # end

        # routing.on String do |query|
        #   routing.get do
        #     jobs_json = ApiGateway.new.jobs(query)
        #     all_jobs = ThxSeafood::JobsRepresenter.new(OpenStruct.new).from_json jobs_json
        #     projects = Views::AllProjects.new(all_jobs)
        #     if projects.none?
        #       flash.now[:error] = 'No data in databse.'
        #     end
        #     if projects.any?
        #       flash.now[:notice] = 'Data is showing below'
        #     end
        #     # view 'ThxSeafood', locals: { projects: projects }
        #     view 'jobmap', locals: { projects: projects }
        #   end
        # end
      end


      routing.on 'hot' do
        # GET /hot/:topnum
        routing.get String do |topnum|
          result = ApiGateway.new.get_top_jobs(topnum)
          view_info = { result: result }

          if result.processing?
            view_info[:processing] = Views::ProcessingView.new(result)
            flash.now[:notice] = 'Hot jobs being processed'
          else
            city_hot_jobs = CityHotJobsRepresenter.new(OpenStruct.new).from_json result.message
            city_hot_jobs_view = Views::CityHotJobsView.new(city_hot_jobs)
            
            view_info[:city_hot_jobs] = city_hot_jobs_view

            # city_hot_jobs_json = CityHotJobsRepresenter.new(city_hot_jobs).to_json
            # projects = Views::JsonAllProjects.new(city_hot_jobs_json)
            
            # view_info[:projects] = projects
            # puts projects.class
            
          end
          view 'hot_job', locals: view_info

        end
      
      end

    end
  end
end
