// Copyright 2022 DeChainers
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// programs map
BPF_TABLE_SHARED("prog", int, int, PROGRAM_TYPE_next_MODE, MAX_PROGRAMS_PER_HOOK);

int internal_handler(struct CTXTYPE *ctx) {
  PROGRAM_TYPE_next_MODE.call(ctx, 0);
  return PASS;
}
