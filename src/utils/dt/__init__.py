import signal
import sys

def sigint_handler(signum, frame):
    sys.exit(-2)

signal.signal(signal.SIGINT, sigint_handler)

from dtschema.lib import (
    format_error,
    extract_compatibles,
    extract_node_compatibles,
    _is_int_schema,
    _is_string_schema,
    _get_array_range,
    sized_int,
)

from dtschema.fixups import (
    fixup_schema,
)

from dtschema.schema import (
    DTSchema,
)

from dtschema.validator import (
    DTValidator,
)

from dtschema.version import (
    __version__
)

import dtschema.dtb
