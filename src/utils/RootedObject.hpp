/*
MIT No Attribution

Copyright 2022 Aidan Lee

Permission is hereby granted, free of charge, to any person obtaining a copy of this
software and associated documentation files (the "Software"), to deal in the Software
without restriction, including without limitation the rights to use, copy, modify,
merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#pragma once

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

namespace cpp
{
    namespace utils {
        class RootedObject
        {
        private:
            bool weak;
            hx::Object** rooted;

        public:
            RootedObject(void*);
            RootedObject(hx::Object**);
            RootedObject(hx::Object*);

            ~RootedObject();

            void makeStrong();
            void makeWeak();
            bool isWeak();
            inline hx::Object** getObjectPtr() const;

            hx::Object* getObject() const;
            void setObject(hx::Object*) const;

            operator hx::Object*() const;
        };
    }
}