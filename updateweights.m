function layers = updateweights(layers, params, regime)

for l = 2 : numel(layers)
  
  if strcmp(layers{l}.type, 'c')
    for i = 1 : layers{l}.outputmaps
      for j = 1 : layers{l-1}.outputmaps
        if (regime == 0)  
          layers{l}.dkp{i, j} = params.momentum * layers{l}.dkp{i, j};
          delta = layers{l}.dkp{i, j};
        else
          layers{l}.dk{i, j} = (1 - params.momentum) * layers{l}.dk{i, j};
          delta = layers{l}.dk{i, j};
          signs = layers{l}.dk{i, j} .* layers{l}.dkp{i, j};          
          layers{l}.dkp{i, j} = layers{l}.dkp{i, j} + delta;
          layers{l}.gk{i, j}(signs > 0) = layers{l}.gk{i, j}(signs > 0) + params.adjustrate;
          layers{l}.gk{i, j}(signs <= 0) = layers{l}.gk{i, j}(signs <= 0) * (1 - params.adjustrate);
          layers{l}.gk{i, j}(layers{l}.gk{i, j} > params.maxcoef) = params.maxcoef;
          layers{l}.gk{i, j}(layers{l}.gk{i, j} <= 1/params.maxcoef) = 1/params.maxcoef;          
        end;
        layers{l}.k{i, j} = layers{l}.k{i, j} - params.alpha * layers{l}.gk{i, j} .* delta;                      
      end             
    end
    
  elseif strcmp(layers{l}.type, 'f')
    if (regime == 0)      
      layers{l}.dwp = params.momentum * layers{l}.dwp;  
      delta = layers{l}.dwp;  
    else
      layers{l}.dw = (1 - params.momentum) * layers{l}.dw;
      delta = layers{l}.dw;
      signs = sign(layers{l}.dw) .* sign(layers{l}.dwp);
      layers{l}.dwp = layers{l}.dwp + delta;  
      layers{l}.gw(signs > 0) = layers{l}.gw(signs > 0) + params.adjustrate;
      layers{l}.gw(signs <= 0) = layers{l}.gw(signs <= 0) * (1 - params.adjustrate);
      layers{l}.gw(layers{l}.gw > params.maxcoef) = params.maxcoef;
      layers{l}.gw(layers{l}.gw <= 1/params.maxcoef) = 1/params.maxcoef;        
    end;  
    layers{l}.w = layers{l}.w - params.alpha * layers{l}.gw .* delta;
    %constr = 0.4;
    %layers{l}.w(layers{l}.w > constr) = constr;
    %layers{l}.w(layers{l}.w < -constr) = -constr;  
  end
  
  % for all transforming layers
  if strcmp(layers{l}.type, 'c') || strcmp(layers{l}.type, 'f')
    if (regime == 0)  
      layers{l}.dbp = params.momentum * layers{l}.dbp;
      delta = layers{l}.dbp;
    else
      layers{l}.db = (1 - params.momentum) * layers{l}.db;
      delta = layers{l}.db;
      signs = sign(layers{l}.db) .* sign(layers{l}.dbp);
      layers{l}.dbp = layers{l}.dbp + delta;
      layers{l}.gb(signs > 0) = layers{l}.gb(signs > 0) + params.adjustrate;
      layers{l}.gb(signs <= 0) = layers{l}.gb(signs <= 0) * (1 - params.adjustrate);
      layers{l}.gb(layers{l}.gb > params.maxcoef) = params.maxcoef;
      layers{l}.gb(layers{l}.gb <= 1/params.maxcoef) = 1/params.maxcoef;              
    end;        
    layers{l}.b = layers{l}.b - params.alpha * layers{l}.gb .* delta;
  end;
end
    
end
