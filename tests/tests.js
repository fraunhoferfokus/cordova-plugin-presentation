/*
 * Copyright 2014 Fraunhofer FOKUS
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * AUTHORS: Louay Bassbouss <louay.bassbouss@fokus.fraunhofer.de>
 *          Martin Lasak <martin.lasak@fokus.fraunhofer.de>
 */

exports.defineAutoTests = function () {
    describe('Presentation API (navigator.presentation)', function () {
        it("should exist", function () {
            expect(navigator.presentation).toBeDefined();
        });

        it("should contain a requestSession function", function () {
            expect(navigator.presentation.requestSession).toBeDefined();
            expect(typeof navigator.presentation.requestSession == 'function').toBe(true);
        });
    });

    //more to come...
};


/******************************************************************************/
/******************************************************************************/
/******************************************************************************/

exports.defineManualTests = function (contentEl, createActionButton) {
    var session;


    function requestSession() {
        session = navigator.presentation.requestSession("receiver.html");
    }


    createActionButton('Request Session', function () {
        requestSession();
    }, 'requestSession');

    //more to come
};
