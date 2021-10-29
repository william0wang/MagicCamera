
import coremltools
from coremltools.models.neural_network import quantization_utils
 
name = 'cpaprika'

model =  coremltools.models.MLModel(name + '.mlmodel')
 
model_fp16 = quantization_utils.quantize_weights(model, nbits=16)
model_fp16.save(name + "16.mlmodel")

# model_fp8 = quantization_utils.quantize_weights(model, nbits=8)
# model_fp8.save(name + "8.mlmodel")
