# Copyright (C) 2014-2015 MongoDB, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'mongo/operation/write/bulk/bulk_mergable'
require 'mongo/operation/write/bulk/legacy_bulk_mergable'

module Mongo
  module Operation
    module Write
      class BulkDelete

        # Defines custom behaviour of results when deleting.
        #
        # @since 2.0.0
        class Result < Operation::Result
          include BulkMergable

          # The aggregate number of deleted docs reported in the replies.
          #
          # @since 2.0.0
          REMOVED = 'nRemoved'.freeze

          # Gets the number of documents deleted.
          #
          # @example Get the deleted count.
          #   result.n_removed
          #
          # @return [ Integer ] The number of documents deleted.
          #
          # @since 2.0.0
          def n_removed
            return 0 unless acknowledged?
            @replies.reduce(0) do |n, reply|
              n += reply.documents.first[N]
            end
          end
        end

        # Defines custom behaviour of results when deleting.
        # For server versions < 2.5.5 (that don't use write commands).
        #
        # @since 2.0.0
        class LegacyResult < Operation::Result
          include LegacyBulkMergable

          # Gets the number of documents deleted.
          #
          # @example Get the deleted count.
          #   result.n_removed
          #
          # @return [ Integer ] The number of documents deleted.
          #
          # @since 2.0.0
          def n_removed
            return 0 unless acknowledged?
            @replies.reduce(0) do |n, reply|
              n += reply.documents.first[N]
            end
          end
        end
      end
    end
  end
end
