# confirm PyTorch sees the GPU
from torch
print('Torch Version: ' + str(torch.__version__))
print('CUDA available: ' + str(torch.cuda.is_available()))
print('CUDA device name: ' + str(torch.cuda.get_device_name(torch.cuda.current_device())))
assert torch.cuda.is_available()
assert torch.cuda.device_count() > 0
a = torch.cuda.FloatTensor(2).zero_()
print('Tensor a = ' + str(a))
b = torch.randn(2).cuda()
print('Tensor b = ' + str(b))
c = a + b
print('Tensor c = ' + str(c))

# confirm Keras sees the GPU
import keras
print('Keras Version: ' + str(keras.__version__))
assert len(keras.backend.tensorflow_backend._get_available_gpus()) > 0
