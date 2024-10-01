import tensorflow as tf
import random

def _flip_left_right(image, label):
    """Randomly flips image and label left or right in accord."""
    seed = random.random()
    image = tf.image.random_flip_left_right(image, seed=seed)
    label = tf.image.random_flip_left_right(label, seed=seed)

    return image, label

def _flip_up_down(image, label):
    """Randomly flips image and label left or right in accord."""
    seed = random.random()
    image = tf.image.random_flip_up_down(image, seed=seed)
    label = tf.image.random_flip_up_down(label, seed=seed)

    return image, label

def _rotate90(image, label):
    '''Randomly rotate k*90 degree'''
    k = tf.random_uniform([1],minval=0,maxval=4,dtype=tf.int32)[0]
    image = tf.image.rot90(image,k)
    label = tf.image.rot90(label,k)

    return image, label


def _normalize_data(image, label):
    """Normalize image and label within range 0-1."""
    image = tf.cast(image, tf.float32)
    image = image / 255.0

    label = tf.cast(label, tf.float32)
    label = label / 255.0

    return image, label


def _parse_data(image_paths, label_paths):
    """Reads image and label files"""

    image_content = tf.read_file(image_paths)
    label_content = tf.read_file(label_paths)

    images = tf.image.decode_png(image_content, channels=3)
    labels = tf.image.decode_png(label_content, channels=3)

    return images, labels


def _read_labeled_image_list(data_list):

    f = open(data_list, 'r')
    images = []
    labels = []
    for line in f:
        image, label = line.strip("\n").split(' ')
        # print 'list'
        # print image
        # print label
        images.append( image)
        labels.append( label)
    return images, labels


def data_batch(data_list, augment=None, normalize=False,batch_size=1, epoch = None):
    """Reads data, normalizes it, shuffles it, then batches it, returns a
       the next element in dataset op and the dataset initializer op.
       Inputs:
        image_paths: A list of paths to individual images
        label_paths: A list of paths to individual label images
        augment: Boolean, whether to augment data or not
        batch_size: Number of images/labels in each batch returned
        num_threads: Number of parallel calls to make
       Returns:
        next_element: A tensor with shape [2], where next_element[0]
                      is image batch, next_element[1] is the corresponding
                      label batch
        init_op: Data initializer op, needs to be executed in a session
                 for the data queue to be filled up and the next_element op
                 to yield batches"""

    # Convert lists of paths to tensors for tensorflow

    num_threads = 10
    num_prefetch = 5*batch_size
    image_list, label_list = _read_labeled_image_list(data_list)
    num_sample = len(image_list)
    images = tf.convert_to_tensor(image_list, dtype=tf.string)
    labels = tf.convert_to_tensor(label_list, dtype=tf.string)

    # Create dataset out of the 2 files:
    data = tf.data.Dataset.from_tensor_slices((images, labels))

    data = data.shuffle(buffer_size=num_sample)

    # Parse images and label
    data = data.map(_parse_data,
                    num_parallel_calls=num_threads).prefetch(num_prefetch)

    # If augmentation is to be applied
    if 'flip_ud' in augment:
        print 'flip_ud'
        data = data.map(_flip_up_down,
                        num_parallel_calls=num_threads).prefetch(num_prefetch)

    if 'flip_lr' in augment:
        print 'flip_lr'
        data = data.map(_flip_left_right,
                        num_parallel_calls=num_threads).prefetch(num_prefetch)

    if 'rot90' in augment:
        print 'rot90'
        data = data.map(_rotate90,
                        num_parallel_calls=num_threads).prefetch(num_prefetch)
    # Normalize
    if normalize:
        data = data.map(_normalize_data,
                        num_parallel_calls=num_threads).prefetch(num_prefetch)

    # Batch, epoch, shuffle the data
    data = data.batch(batch_size)
    data = data.repeat(epoch)

    # Create iterator
    iterator = data.make_one_shot_iterator()

    # Next element Op
    next_element = iterator.get_next()

    return next_element, init_op
