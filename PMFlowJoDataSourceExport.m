classdef PMFlowJoDataSourceExport
    %PMFLOWJODATASOURCEEXPORT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = private)
        dataSource
        ExportFolder
        figureTitle
        panelPositions
        MainExportFolder
        
    end
    
    methods
        function obj = PMFlowJoDataSourceExport(varargin)
            %PMFLOWJODATASOURCEEXPORT Construct an instance of this class
            %   Detailed explanation goes here
            switch length(varargin)
                    case 5
                    obj.dataSource =        varargin{1};
                    obj.ExportFolder =        varargin{2};
                    
                    obj.panelPositions =        varargin{3};
                    obj.MainExportFolder =        varargin{4};
                   obj.figureTitle =        varargin{5};
                
            end
        end
        
        function obj = export(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            obj =           obj.exportFlowSpreadSheetsIntoFile;
            obj =           obj.exportAllPValuesIntoSpreadSheet;
            
            xyPanelSeries = obj.getInitializedFlowXYPanelSeries;
           
            obj =           obj.exportXYPanelSeries(...
                                    xyPanelSeries...
                                    );
        end
    end
    
    methods (Access = private)
       
           function obj = exportFlowSpreadSheetsIntoFile(obj)
            
               
       
            targetFileNames =               cellfun(@(x) [[x{:}], '.text'], obj.dataSource.getFileCodes, 'UniformOutput', false);
            for index = 1 : length(targetFileNames)
                CurrentName = targetFileNames{index};
                 if length(CurrentName) > 80
                    CurrentName = ['Pooled_' CurrentName(1:60), '.text'];

                 end

                targetFileNames{index} = CurrentName;
            end

            sheetsFromDataSource=       obj.dataSource.getGroupStatisticsSeries.getFormattedSpreadsheets;
            
                cellfun(@(x, y) PMFile(...
                        [obj.MainExportFolder,  [obj.ExportFolder, '_Spreadsheets']],  x).writeCellString(y), ...
                        targetFileNames, ...
                        sheetsFromDataSource) ;

            
            
            
        end
        
        function obj = exportAllPValuesIntoSpreadSheet(obj)
           
            exportSummaryFile =             PMFile([obj.MainExportFolder, [obj.ExportFolder, '_Figures']], '0_PValueSummary.csv');    
            mySpreadSheet =                 obj.dataSource.getGroupStatisticsSeries.getPValueSpreadSheet;
            mySpreadSheet{1,2} =            obj.dataSource.getColumnTitles;
            exportSummaryFile.writeCellString(mySpreadSheet);
            
        end
        
        function obj = exportXYPanelSeries(obj, xyPanelSeries)
            
            
            
            FigureNumber =                  1;
            for Index = 1: xyPanelSeries.getNumberOfDataTypes
                xyPanelSeries =         xyPanelSeries.setActiveIndex(Index);

                myFigure =              PMSVGFigure(...
                                                FigureNumber, ...
                                                [[0] , [0]], ...
                                                {xyPanelSeries},  ...
                                                [obj.MainExportFolder,   [obj.ExportFolder, '_Figures']], ...
                                                [ xyPanelSeries.getDescriptionForActiveParameter, '.svg']...
                                                );
                myFigure.writeFigureIntoFile;
            end 

            
        end
        
        function xyPanelSeries = getInitializedFlowXYPanelSeries(obj)
            
            xyPanelSeries =         PMSVGDocument_XYPanelSeries(...
                                                obj.dataSource.getGroupStatisticsSeries, ...
                                                obj.dataSource.getNumberOfRows);

            xyPanelSeries =         obj.setDefaultSymbolFormattingOfPanel(xyPanelSeries);
          
                                             
            xyPanelSeries =         xyPanelSeries.setSelectedGroups(obj.dataSource.getSelectedGroups);
            
            xyPanelSeries =         xyPanelSeries.setFigureTitle(obj.figureTitle);
            xyPanelSeries =         xyPanelSeries.setPanelTitles(obj.dataSource.getPanelTitles);
            xyPanelSeries =         xyPanelSeries.setPanelTitlePosition([0, 0]);
            xyPanelSeries =         xyPanelSeries.setFontSizeOfPanelTitles('10');
            
            xyPanelSeries =         xyPanelSeries.setManualPanelLocations(obj.panelPositions);
            xyPanelSeries =         xyPanelSeries.setPanelSize([300, 200]);
            xyPanelSeries  =        xyPanelSeries.setGapBetweenRows(0);
            xyPanelSeries  =        xyPanelSeries.setGapBetweenColumns(30);

            xyPanelSeries =         xyPanelSeries.setRelativeAxesPositions([60 270 50 180]);
            xyPanelSeries =         xyPanelSeries.setYMaxSameInEachPanel(false);
            xyPanelSeries =         xyPanelSeries.setHideViolin(true);
            
           
              
            
            
            
        end
        
           function panel = setDefaultSymbolFormattingOfPanel(obj, panel)
            panel =             panel.setSymbolStyle( ...
                                            PMSVGStyle('none', '1', '#0099ff',  '', 'Ellipse'));
            panel =             panel.setSymbolSize( 9);
           end
        
        
        
    end
end

