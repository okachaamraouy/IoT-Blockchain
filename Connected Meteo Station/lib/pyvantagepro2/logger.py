"""
    pyvantagepro2.logger
    -------------------

    Logging setup.


"""

from ..logging.logging import *
from .compat import NullHandler


LOGGER = getLogger('pyvpdriver')
LOGGER.addHandler(NullHandler())


def active_logger():
    '''Initialize a speaking logger with stream handler (stderr).'''
    LOGGER = getLogger('pyvpdriver')

    LOGGER.setLevel(logging.INFO)
    logging.getLogger('pylink').setLevel(logging.INFO)

    # Default to logging to stderr.
    formatter = logging.Formatter('%(asctime)s %(levelname)s: %(message)s ')
    stream_handler = logging.StreamHandler()
    stream_handler.setFormatter(formatter)

    LOGGER.addHandler(stream_handler)
    logging.getLogger('pylink').addHandler(stream_handler)
