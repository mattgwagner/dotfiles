using FakeItEasy;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging.Abstractions;
using Newtonsoft.Json;
using PureCloudPlatform.Client.V2.Api;
using PureCloudPlatform.Client.V2.Model;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Security.Claims;
using System.Threading.Tasks;
using Xunit;

namespace RedLegDev.Tests
{
    public class ApiFunctionTests
    {
        [Fact]
        public async Task GetInteractionsDataHttpTest()
        {
            var start = new DateTime(2021, 12, 18);

            var end = new DateTime(2021, 12, 21);

            var instance = new GetInteractionsDataHttp(NullLogger<GetInteractionsDataHttp>.Instance);

            var context = A.Fake<FunctionContext>();

            var uri = new Uri($"https://whatever?start_date={start}&end_date={end}");

            var request = new FakeHttpRequestData(context, uri);

            var result = await instance.Run(request, context);

            Assert.NotNull(result);

            result.Body.Position = 0;

            var body = await new StreamReader(result.Body).ReadToEndAsync();

            File.WriteAllText($"{nameof(GetInteractionsDataHttpTest)}-{start:yyyyMMdd}-{end:yyyyMMdd}.json", body);
        }

        public class FakeHttpRequestData : HttpRequestData
        {
            public FakeHttpRequestData(FunctionContext functionContext, Uri url, Stream body = null) : base(functionContext)
            {
                Url = url;
                Body = body ?? new MemoryStream();
            }

            public override Stream Body { get; } = new MemoryStream();

            public override HttpHeadersCollection Headers { get; } = new HttpHeadersCollection();

            public override IReadOnlyCollection<IHttpCookie> Cookies { get; }

            public override Uri Url { get; }

            public override IEnumerable<ClaimsIdentity> Identities { get; }

            public override string Method { get; }

            public override HttpResponseData CreateResponse()
            {
                return new FakeHttpResponseData(FunctionContext);
            }
        }

        public class FakeHttpResponseData : HttpResponseData
        {
            public FakeHttpResponseData(FunctionContext functionContext) : base(functionContext)
            {
            }

            public override HttpStatusCode StatusCode { get; set; }
            public override HttpHeadersCollection Headers { get; set; } = new HttpHeadersCollection();
            public override Stream Body { get; set; } = new MemoryStream();
            public override HttpCookies Cookies { get; }
        }
    }
}
