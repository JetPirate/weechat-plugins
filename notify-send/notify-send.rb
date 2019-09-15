# notify-send
# ruby script to write hilights and PMs to notify-send
#
# Author: Oleh Fedorenko <fpostoleh@gmail.com>
#
# Copyright (c) 2019 Oleh Fedorenko
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'date'

SCRIPT_NAME = 'notify-send'
SCRIPT_AUTHOR = 'Oleh Fedorenko <fpostoleh@gmail.com>'
SCRIPT_DESC = 'Send highlights and private message to notify-send'
SCRIPT_VERSION = '0.0.1'
SCRIPT_LICENSE = 'MIT'

HISTORY_PATH = '~/.weechat/history/'

def weechat_init
  Weechat.register(SCRIPT_NAME, SCRIPT_AUTHOR, SCRIPT_VERSION, SCRIPT_LICENSE, SCRIPT_DESC, '', '')
  Weechat.hook_print('', 'notify_message', '', 1, 'hilite', '')
  Weechat.hook_print('', 'notify_private', '', 1, 'private', '')
  Weechat::WEECHAT_RC_OK
end

def send(subtitle, message)
  msg = "#{subtitle}:\n#{message}\n"
  summary = 'IRC Message'
  body = "#{msg}"
  `notify-send "#{summary}" "#{body}" >/dev/null 2>&1`
  filename = "msgs-#{DateTime.now.strftime('%d-%m-%Y')}"
  file = File.join(File.expand_path(HISTORY_PATH), filename)
  File.open(file, 'a') do |f|
    f.write(body)
  end
rescue StandardError
  Weechat::WEECHAT_RC_OK
end

def hilite(data, buffer, date, tags, visible, highlight, prefix, message)
  unless highlight.to_i.zero?
    data = {}
    %w[type channel server].each do |meta|
      data[meta.to_sym] = Weechat.buffer_get_string(buffer, "localvar_#{meta}");
    end

    if data[:type] == 'channel'
      subtitle = "#{data[:server]}##{data[:channel]} Highlight"
      send(subtitle, message)
    end
  end
  Weechat::WEECHAT_RC_OK
end

def private(data, buffer, date, tags, visible, highlight, prefix, message)
  data = {}
  %w[type channel server].each do |meta|
    data[meta.to_sym] = Weechat.buffer_get_string(buffer, "localvar_#{meta}");
  end

  unless data[:channel] == data[:server]
    subtitle = "Private message from #{data[:channel]}"
    send(subtitle, message)
  end
  Weechat::WEECHAT_RC_OK
end
