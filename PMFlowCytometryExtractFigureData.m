classdef PMFlowCytometryExtractFigureData
    %PMFLOWCYTOMETRYEXTRACTFIGUREDATA Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        DataSource
        
        Groups
        TimePoints
        
    end
    
    methods
        function obj = PMFlowCytometryExtractFigureData(varargin)
            %PMFLOWCYTOMETRYEXTRACTFIGUREDATA Construct an instance of this class
            %   Detailed explanation goes here
            obj.DataSource = DataSource;
        end
        
        function dataContainers = getDataContainers(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
           dataContainers = 1;
        end
    end
end

