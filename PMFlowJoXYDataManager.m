classdef PMFlowJoXYDataManager
    %PMFLOWJOXYDATAMANAGER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = private)
        XYData
        
        ExperimentKey
        ParameterName
        YMin
        YMax
        RowTitleFileName
        SelectedGroups
        DataType
        MyRange
    end
    
    methods
        function obj = PMFlowJoXYDataManager(XYData, varargin)
            %PMFLOWJOXYDATAMANAGER Construct an instance of this class
            %   Detailed explanation goes here
             switch length(varargin)
               
                case 7
                    obj.XYData=                             XYData;
                    obj.ExperimentKey =                         varargin{1};
                    obj.ParameterName =                         varargin{2};
                    obj.YMin =                                  varargin{3};
                    obj.YMax =                                  varargin{4};
                    obj.RowTitleFileName =                      varargin{5};
                    obj.SelectedGroups =                        varargin{6};
                    obj.DataType =                              varargin{7};
                    
                case 8
                     obj.XYData=                             XYData;
                    obj.ExperimentKey =                         varargin{1};
                    obj.ParameterName =                         varargin{2};
                    obj.YMin =                                  varargin{3};
                    obj.YMax =                                  varargin{4};
                    obj.RowTitleFileName =                      varargin{5};
                    obj.SelectedGroups =                        varargin{6};
                    obj.DataType =                              varargin{7};
                    obj.MyRange =                                 varargin{8};
                    
                 otherwise
                    error('Wrong input.')
                
                
            end
             
        end
        
          function XYData = getXYData(obj, varargin)
            
                  XYData =        obj.XYData.getXYData(...
                                                    obj.ExperimentKey, obj.ParameterName, obj.RowTitleFileName, obj.SelectedGroups, obj.DataType, obj.MyRange ...
                                                    );
            
        end
        
 
    end
end

