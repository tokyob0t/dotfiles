local argparse = require('argparse')

local parser = argparse()
    :name('Luar')
    :description('Client to control running GTK shell instances.')
    :epilog('For more information, visit http://example.com')

parser:flag('-v --version', 'Print version information and exit.')
parser:flag('-l --list', 'List available windows and exit.')
parser:flag('-q --quit', 'Quit the GTK application.')
parser:flag('-i --inspector', 'Open the GTK debug inspector.')
parser:option('-t --toggle-window', 'Show or hide a specific window (by name or ID).')

parser._print = function(...) print('WEA', ...) end

return parser
