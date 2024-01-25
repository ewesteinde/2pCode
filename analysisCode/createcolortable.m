function ct = createcolortable(colorA,colorB,varargin)
%  COLORTABLE = CREATECOLORTABLE(COLORA,COLORB,{NUMCOLORS},{IDX})
%   Create a color table from two RGB tuples
%
%  COLORA, COLORB are 3-element vectors in any orientation
%     Currently, this tool expects these to be normalized FP tuples.
%  NUMCOLORS specifies the length of the color table (default 256)
%  IDX optionally specifies the index within the color table
%     By default, the entire color table is returned.  This parameter
%     allows the user to specify a specific index or range of indices
%     from within the color table.  Non-integer indices are supported.
%
%  Output is an array of size NUMCOLORSx3

numcolors = 256;

if numel(varargin)>=1
	numcolors = varargin{1};
end
if numel(varargin)>=2
	n = varargin{2};
else
	n = 1:numcolors;
end
	
colorA = reshape(colorA,1,[]);
colorB = reshape(colorB,1,[]);
ct = interp1([1/numcolors 1],[colorA; colorB],n/numcolors);

end