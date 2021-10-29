import tensorflow as tf
import numpy as np
import coremltools as ct

from coremltools.models.neural_network import quantization_utils
import coremltools.proto.FeatureTypes_pb2 as FeatureTypes_pb2

path = "/Users/william/Downloads/AttGAN_384/generator.pb"

# Load the protobuf file from the disk and parse it to retrieve the
# graph_def
with tf.io.gfile.GFile(path, "rb") as f:
    graph_def = tf.compat.v1.GraphDef()
    graph_def.ParseFromString(f.read())

# Import the graph_def into a new Graph
with tf.Graph().as_default() as graph:
    tf.import_graph_def(graph_def, name="generator")

x = np.random.rand(1, 384, 384, 3)

y = np.ones([1, 13], dtype=float)


with tf.compat.v1.Session(graph = graph) as sess:
    tf_out = sess.run('generator/xb:0',
                      feed_dict={'generator/xa:0': x, 'generator/b_:0':y})

mlmodel = ct.convert(graph, source="tensorflow", 
                     inputs=[ct.TensorType(shape=x.shape), ct.TensorType(shape=y.shape)])

model_fp8 = quantization_utils.quantize_weights(mlmodel, nbits=8)


spec = model_fp8.get_spec()

input = spec.description.input[1]
input.type.imageType.colorSpace = FeatureTypes_pb2.ImageFeatureType.RGB
input.type.imageType.height = 384
input.type.imageType.width = 384

ct.utils.rename_feature(spec, 'generator/xa', 'input')
ct.utils.rename_feature(spec, 'generator/b_', 'style')
ct.utils.rename_feature(spec, 'generator/xb', 'output')

# ct.utils.save_spec(spec, "attgen8.mlmodel")

model_fp8._spec = spec

model_fp8.save("attgen8.mlmodel")

# Core ML model prediction
# coreml_out_dict = model_fp8.predict({"input" : x, "style": y}, useCPUOnly=True)
# coreml_out = list(coreml_out_dict.values())[0]
# np.testing.assert_allclose(tf_out, coreml_out, rtol=1e-3, atol=1e-2)
