#ifndef EASYWSCLIENT_H
#define EASYWSCLIENT_H

#include <string>
#include <functional>

// هنا يتم استخدام المكتبة الخاصة بالـ WebSocket.
// يمكنك استخدام مكتبات مثل `asio` أو `libwebsocket` هنا، لكننا سنبسطها في هذا المثال.

namespace easywsclient {
    class WebSocket {
    public:
        typedef std::shared_ptr<WebSocket> pointer;

        // الدالة لإنشاء الاتصال مع السيرفر
        static pointer from_url(const std::string& url);

        // دالة لإرسال البيانات عبر WebSocket
        virtual void send(const std::string& message) = 0;

        // دالة للتحقق إذا كانت الاتصال مغلق أو متصل
        virtual bool is_open() const = 0;

        // دالة لإغلاق الاتصال
        virtual void close() = 0;

        // دالة لاستقبال البيانات من السيرفر
        virtual void poll() = 0;

        virtual ~WebSocket() {}
    };
}

#endif // EASYWSCLIENT_H
