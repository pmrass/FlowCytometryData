classdef PMTimeCourseDataContainer
    %PMTIMECOURSEDATACONTAINER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        DataSources
        DataProcessingIdentifier
        
        Parameter
        TimeUnit
        RawData
        
    end
    
    methods
        function obj = PMTimeCourseDataContainer(varargin)
            %PMTIMECOURSEDATACONTAINER Construct an instance of this class
            %   Detailed explanation goes here
            switch length(varargin)
                case 0
                    
                otherwise
                    error('Wrong input.')
                
            end
            
        end
        
        function obj = showSummary(obj)
            
            fprintf('\n*** This PMTimeCourseDataContainer object contains data related to a time-course analysis.\n')
            fprintf('The source-files that were used to create this object were:\n')
            cellfun(@(x) fprintf('%s\n', x), obj.DataSources)
            fprintf('Description of how source-files were converted into PMTimeCourseDataContainer: "%s"\n', obj.DataProcessingIdentifier)
            fprintf('This object contains data describing the parameter "%s" and the time-unit "%s".\n', obj.Parameter, obj.TimeUnit)
            
            
        end
        
        function dataContainer = getXVsYDataContainerForSpecimen(obj, Name)
            %GETXVSYDATACONTAINERFORSPECIMEN returns PMXVsYDataContainer for specimen-name; 
            %   Detailed explanation goes here  
            RowIndices =              strcmp(obj.RawData(:,1), Name);
            MyData =                obj.RawData(RowIndices, 2:3);
            
            dataContainer =         PMXVsYDataContainer(MyData, Name, obj.Parameter);

            obj =                   obj.showSummary;
            obj.showDataDescriptionForSpecimenAndData(Name, MyData);
            
        end
        
        
      
        
    end
    
    
    methods (Access = private)
        
        function  obj = showDataDescriptionForSpecimenAndData(obj, Specimen, MyData)
            fprintf('\nData for speciment "%s" and parameter "%s" were retrieved.\n', Specimen, obj.Parameter)
            fprintf('The following data were found:\n')
           
            for index = 1 : size(MyData, 1)
               
                fprintf('%s: %i\n', obj.TimeUnit, MyData{index, 1})
              
                arrayfun(@(x) fprintf('%6.2f ', x), MyData{index, 2})
                fprintf('\n')
            end
            
            
        end
        
        
        
    end
    
    
    
    
end

